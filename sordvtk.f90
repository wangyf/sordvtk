
program sordvtk
! Feb 2017 version 1.1 only output nodal field (done)
! Jul 2017 version 1.2 add output nodal and cellar field (done)
! Jul 2017 version 1.3 add output vector (nodal & cellar) field (done)
! Mar 2022 version 1.3 add output format (binary or ascii) (done)

use IR_Precision
use Lib_VTK_IO
use m_strings
use m_byteswap


  implicit none
  integer ::   nx,ny,nz,nt
  integer ::   nn, nc, i,j,k,l,io, ioc, nw, ndt
  real, allocatable, dimension(:,:,:):: x,y,z
  real, allocatable, dimension(:,:,:,:):: f3d
  integer:: E_IO, data_endian, it, cf, nfield,iab
  real :: time, dt
  CHARACTER(LEN=1024) :: line, words(40)
  CHARACTER(LEN=80) :: outstr,filename,output_format
  CHARACTER(LEN=8) :: fmt
  logical :: input_swap
  !!!!!
  character(len=80) :: in_folder, ou_folder, typename(10), bname(10),varname(10),  &
                       geox,geoy,geoz,fname
  integer :: n1,n2
  
  !output time dependent vts-> timestep stamp format
  fmt = '(I5.5)'

  call check_endian() !function is in IR_Precision(endian == 1 little; == 0 big)
  
  write(0,'(A)')' Write vts files'
  
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! Input binary data files
  ! v1.0 : structured, node, points, scaler
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! input format
  ! in_foldername   # folder name storing binary input data
  ! out_foldername  # folder name to store binary output data (out_binary =in_binary+.vts) 
  ! n1 # fo single file ->static.vts
  ! varname,geox,geoy,geoz,nx,ny,nz,nfield,n(nodal),fname,varname, ...
  ! ...
  ! n2 # of files: time variable file -> timedependent.pvd
  ! varname,geox,geoy,geoz,nx,ny,nz,nt,dt,ndt(skip nt for output),nfield,n(nodal),fname,varname, ...
  ! ...
  ! end
  
  !!! data byte_order
  read(*,'(A)') line
  select case(trim(line))
    case('littleendian'); data_endian = 1;
    case('bigendian'); data_endian = 0;
  end select
  
  if (data_endian == endian) then
    input_swap = .false.
  else
    input_swap = .true.
  end if
  
  read(*,'(A)') in_folder
  read(*,'(A)') ou_folder  
  print *,in_folder
  print *,ou_folder

  read(*,'(A)') output_format
  select case(trim(output_format))
  case('ASCII')
    write(0,*) 'Output format is ASCII'
  case('BINARY')
    write(0,*) 'Output format is BINARY'
  case default
    stop "Please assign output format (ASCII or BINARY)"
  end select

  read(*,*) n1
  ! convert non-time dependent files
  if (n1 > 0) then


  file1: do i = 1,n1
  	read(*,'(A)') line
	call parse(line, ' ', words, nw) 
	read(words(1), *) filename
	read(words(2:4),*) geox,geoy,geoz
	read(words(5:7),*) nx,ny,nz
	read(words(8), *) nfield
	field: do j = 1, nfield
		read(words((8+1+(j-1)*3):(8+3+(j-1)*3)),*) typename(j),bname(j),varname(j)
		write(0,'(6A10)') 'Type = ',typename(j),'file = ',bname(j),'varname = ', varname(j)
	end do field
	
	!write(0,'(4A10)') 'file = ',bname(2),'varname = ', varname(2)
  	!!!! allocate geometry and field
  	allocate(x(nx,ny,nz))
  	allocate(y(nx,ny,nz))
  	allocate(z(nx,ny,nz))
  	nn = nx * ny * nz
  	nc = (nx-1) * (ny-1) * (nz-1)
  	!!!! read binary data from SORD
  	inquire( iolength=io) x(:,:,1)
  	
      fname = trim(in_folder)//'/'//trim(geox)
      open(1, file=fname,recl=io, form='unformatted', access='direct', &
        status='old')
      do l = 1, nz 
        read(1,rec=l) ((x(j,k,l),j=1,nx),k=1,ny)
      enddo   
      close(1)
      
      fname = trim(in_folder)//'/'//trim(geoy)
      open(1, file=fname,recl=io, form='unformatted', access='direct', &
        status='old')
      do l = 1, nz
        read(1,rec=l) ((y(j,k,l),j=1,nx),k=1,ny)
      enddo
      close(1)
      
      fname = trim(in_folder)//'/'//trim(geoz)
      open(1, file=fname,recl=io, form='unformatted', access='direct', &
        status='old')
      do l = 1, nz
        read(1,rec=l) ((z(j,k,l),j=1,nx),k=1,ny)
      enddo  
      close(1)

      !!!! swap byte
      if (input_swap) then
        write(0,*) 'Input Data Swap Byte order'
#ifdef r8
        call SWAPR83D(x)
        call SWAPR83D(y)
        call SWAPR83D(z)
#else
        call SWAPR43D(x)
        call SWAPR43D(y)
        call SWAPR43D(z)
#endif
      end if
      
  	allocate(f3d(nfield,nx,ny,nz))
  	
  	inquire( iolength=ioc) x(1:nx-1,1:ny-1,1) !assume nz > 1

      do iab = 1, nfield
      	fname = trim(in_folder)//'/'//trim(bname(iab))
      	write(0,*) 'Read file ->',bname(iab)
      	
      	if (typename(iab) == 'n') then
      	  open(1, file=fname,recl=io, form='unformatted', access='direct', &
        		status='old')
          do l = 1, nz
      	   read(1,rec=l) ((f3d(iab,j,k,l),j=1,nx),k=1,ny)
          enddo
      	  close(1)
#ifdef r8
      	  if (input_swap) call SWAPR83D(f3d(iab,:,:,:))
#else
          if (input_swap) call SWAPR43D(f3d(iab,:,:,:))
#endif
      	elseif (typename(iab) =='c') then
      	  open(1, file=fname,recl=ioc, form='unformatted', access='direct', &
        		status='old')
          do l = 1, nz-1
      	   read(1,rec=l) ((f3d(iab,j,k,l),j=1,nx-1),k=1,ny-1)
          enddo  
      	  close(1)
#ifdef r8
      	  if (input_swap) call SWAPR83D(f3d(iab,1:nx-1,1:ny-1,1:nz-1))
#else
          if (input_swap) call SWAPR43D(f3d(iab,1:nx-1,1:ny-1,1:nz-1))
#endif
      	else
      	  write(0,*) 'Type no exist';stop
      	end if     	
  	end do
  	
  	fname = trim(ou_folder)//'/'//trim(filename)//'.vts'
      E_IO = VTK_INI_XML(output_format=output_format,filename=fname,mesh_topology='StructuredGrid',&
            nx1=1,nx2=nx,ny1=1,ny2=ny,nz1=1,nz2=nz)
      E_IO = VTK_GEO_XML(nx1=1,nx2=nx,ny1=1,ny2=ny,nz1=1,nz2=nz,NN=nn,X=x,Y=y,Z=z)
  	
  	E_IO = VTK_DAT_XML(var_location='node',var_block_action='open')
  	do iab = 1, nfield
  	  if(typename(iab) == 'n') then
!  	      write(0,*) 'Write ',trim(varname(iab))
  		E_IO = VTK_VAR_XML(NC_NN=nn,varname=trim(varname(iab)),var=f3d(iab,:,:,:))
  		
!  		write(0,*) 'Write Over'
	  end if
	end do
	E_IO = VTK_DAT_XML(var_location='node',var_block_action='close')
	
	E_IO = VTK_DAT_XML(var_location='cell',var_block_action='open')
	do iab = 1, nfield 
  	  if(typename(iab) == 'c') then
!  	      write(0,*) 'Write ',trim(varname(iab))
  		E_IO = VTK_VAR_XML(NC_NN=nc,varname=trim(varname(iab)),var=f3d(iab,1:nx-1,1:ny-1,1:nz-1))
!  		write(0,*) 'Write Over'
	  end if
  	end do
  	E_IO = VTK_DAT_XML(var_location='cell',var_block_action='close')
      
      E_IO = VTK_GEO_XML()
  	E_IO = VTK_END_XML()
      deallocate(x,y,z,f3d)
  end do file1

end if  
  
  
  !!!!!!!!!!!!!! time dependent file
  read(*,*) n2
if (n2 > 0) then


  file2: do i = 1, n2
  	read(*,'(A)') line
  	write(*,*) trim(line)
	call parse(line, ' ', words, nw) 
	read(words(1), *) filename
	read(words(2:4),*) geox,geoy,geoz
	read(words(5:10),*) nx,ny,nz,nt,dt,ndt !ndt is used to export vtk every n dt 
	read(words(11), *) nfield
	field2: do j = 1, nfield
		read(words((11+1+(j-1)*3):(11+3+(j-1)*3)),*) typename(j),bname(j),varname(j)
		write(0,'(6A10)') 'Type = ',typename(j),'file = ',bname(j),'varname = ', varname(j)
	end do field2
  
  	allocate(x(nx,ny,nz))
  	allocate(y(nx,ny,nz))
  	allocate(z(nx,ny,nz))
  	nn = nx * ny * nz
  	nc = (nx-1) * (ny-1) * (nz-1)
  	inquire( iolength=io) x(:,:,1)
  	inquire( iolength=ioc) x(1:nx-1,1:ny-1,1)
  	
      fname = trim(in_folder)//'/'//trim(geox)
      open(1, file=fname,recl=io, form='unformatted', access='direct', &
        status='old')
      do l = 1, nz
        read(1,rec=l) ((x(j,k,l),j=1,nx),k=1,ny)
      enddo 
      close(1)
      
      fname = trim(in_folder)//'/'//trim(geoy)
      open(1, file=fname,recl=io, form='unformatted', access='direct', &
        status='old')
      do l = 1, nz
        read(1,rec=l) ((y(j,k,l),j=1,nx),k=1,ny)
      enddo
      close(1)
      
      fname = trim(in_folder)//'/'//trim(geoz)
      open(1, file=fname,recl=io, form='unformatted', access='direct', &
        status='old')
      do l = 1, nz
        read(1,rec=l) ((z(j,k,l),j=1,nx),k=1,ny)
      enddo 
      close(1)

      !!!! swap byte
      if (input_swap) then
        write(0,*) 'Input Data Swap Byte order'
#ifdef r8
        call SWAPR83D(x)
        call SWAPR83D(y)
        call SWAPR83D(z)
#else
        call SWAPR43D(x)
        call SWAPR43D(y)
        call SWAPR43D(z)
#endif
      end if
      
      allocate(f3d(nfield,nx,ny,nz))
      

      
      !each time step
	do iab = 1, nfield
		fname = trim(in_folder)//'/'//trim(bname(iab))
      		!write(0,*) 'Read file ->',bname(iab)
      	if (typename(iab) == 'n') then 
      	    open(iab*100, file=fname,recl=io, form='unformatted', access='direct', &
        			status='old')
        	elseif(typename(iab) == 'c') then
        	    open(iab*100, file=fname,recl=ioc, form='unformatted', access='direct', &
        			status='old')
        	else
      	  write(0,*) 'Type no exist';stop
      	end if
	end do
	
	!Inital PVD file
      fname = trim(ou_folder)//'/'//trim(filename)//'.pvd'
      E_IO = PVD_INI_XML(fname,cf)
      
      write(0,*) nt,ndt,dt
  	timestep: do it = 1, nt, ndt
  		time = (it - 1)*dt
  		write(outstr,fmt) it
  		
  		do iab = 1, nfield
  		    if (typename(iab) == 'n') then 			
            do l = 1, nz
			       read(iab*100,rec=(it-1)*nz+l) ((f3d(iab,j,k,l),j=1,nx),k=1,ny)
            enddo
#ifdef r8
          if (input_swap) call SWAPR83D(f3d(iab,:,:,:))
#else
          if (input_swap) call SWAPR43D(f3d(iab,:,:,:))
#endif
  		    elseif(typename(iab) == 'c') then
            do l = 1, nz-1
  		        read(iab*100,rec=(it-1)*(nz-1)+l) ((f3d(iab,j,k,l),j=1,nx-1),k=1,ny-1)
            enddo
#ifdef r8
          if (input_swap) call SWAPR83D(f3d(iab,1:nx-1,1:ny-1,1:nz-1))
#else
          if (input_swap) call SWAPR43D(f3d(iab,1:nx-1,1:ny-1,1:nz-1))
#endif
  		    else
      	  	write(0,*) 'Type no exist';stop
      	    end if
  		end do
  		 		
		fname = trim(ou_folder)//'/'//trim(filename)//trim(outstr)//'.vts'
      	E_IO = VTK_INI_XML(output_format=output_format,filename=fname,mesh_topology='StructuredGrid',&
            	nx1=1,nx2=nx,ny1=1,ny2=ny,nz1=1,nz2=nz)
      	E_IO = VTK_GEO_XML(nx1=1,nx2=nx,ny1=1,ny2=ny,nz1=1,nz2=nz,NN=nn,X=x,Y=y,Z=z)
  		
  		E_IO = VTK_DAT_XML(var_location='node',var_block_action='open')
  	      do iab = 1, nfield
  	         if(typename(iab) == 'n') then
!  	      write(0,*) 'Write ',trim(varname(iab))
  		   E_IO = VTK_VAR_XML(NC_NN=nn,varname=trim(varname(iab)),var=f3d(iab,:,:,:))
  		
!  		write(0,*) 'Write Over'
	         end if
	      end do
	      E_IO = VTK_DAT_XML(var_location='node',var_block_action='close')
	
	      E_IO = VTK_DAT_XML(var_location='cell',var_block_action='open')
	      do iab = 1, nfield 
  	      if(typename(iab) == 'c') then
!  	      write(0,*) 'Write ',trim(varname(iab))
  		   E_IO = VTK_VAR_XML(NC_NN=nc,varname=trim(varname(iab)),var=f3d(iab,1:nx-1,1:ny-1,1:nz-1))
!  		write(0,*) 'Write Over'
	      end if
  	      end do
  	      E_IO = VTK_DAT_XML(var_location='cell',var_block_action='close')
  		
      	E_IO = VTK_GEO_XML()
  		E_IO = VTK_END_XML()
  		
  		E_IO = PVD_DAT_XML(filename=trim(filename)//trim(outstr)//'.vts',timestep=time,cf=cf)
  		write( 0, '(a)', advance='no' ) '.'
		if ( modulo( it, 50 ) == 0 .or. it == nt ) write( 0, '(i6)' ) it
  	end do timestep
      E_IO = PVD_END_XML(cf)
      
      do iab = 1, nfield
      	close(iab*100)
      end do

  	deallocate(x,y,z,f3d)

  end do file2
end if

end program
