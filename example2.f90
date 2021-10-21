program example1

use Lib_VTK_IO


implicit none
  integer, parameter::   nx1=0,nx2=2,ny1=0,ny2=1,nz1=0,nz2=1
  integer, parameter::   nn=(nx2-nx1+1)*(ny2-ny1+1)*(nz2-nz1+1)
  integer, parameter::   nc=(nx2-nx1)*(ny2-ny1)*(nz2-nz1)
  real, dimension(nx1:nx2,ny1:ny2,nz1:nz2):: x,y,z
  real, dimension(nx1:nx2,ny1:ny2,nz1:nz2):: v_R, v_R2
  real, dimension(nx1:nx2-1,ny1:ny2-1,nz1:nz2-1) :: v_c
  integer::                                  E_IO, io
  integer::                                  i,j,k,l, cf, step
  real :: time
  CHARACTER(LEN=15) :: str,str2
  CHARACTER(LEN=8) :: fmt
  
  fmt = '(I5.5)'

  write(0,'(A)')' Testing StructuredGrid functions. Output files is XML_STRG.vts'
  ! initializing data
  do k=nz1,nz2
    do j=ny1,ny2
      do i=nx1,nx2
        x(  i,j,k) = i
        y(  i,j,k) = j
        z(  i,j,k) = k
        v_R(i,j,k) = i
      enddo
    enddo
  enddo
  
    do k=nz1,nz2-1
    do j=ny1,ny2-1
      do i=nx1,nx2-1
        v_c(i,j,k) = i
      enddo
    enddo
  enddo
  
  ! example binary output
  inquire( iolength=io) x(:,:,:)
  open(1, file='x',recl=io, form='unformatted', access='direct', &
        status='replace')
      write(1,rec=1) (((x(j,k,l),j=nx1,nx2),k=ny1,ny2),l=nz1,nz2)  
  close(1)
  open(1, file='y',recl=io, form='unformatted', access='direct', &
        status='replace')
      write(1,rec=1) (((y(j,k,l),j=nx1,nx2),k=ny1,ny2),l=nz1,nz2)  
  close(1)
  open(1, file='z',recl=io, form='unformatted', access='direct', &
        status='replace')
      write(1,rec=1) (((z(j,k,l),j=nx1,nx2),k=ny1,ny2),l=nz1,nz2)  
  close(1)
    open(1, file='v_n',recl=io, form='unformatted', access='direct', &
        status='replace')
      write(1,rec=1) (((v_R(j,k,l),j=nx1,nx2),k=ny1,ny2),l=nz1,nz2)  
  close(1)
    inquire( iolength=io) x(nx1:nx2-1,ny1:ny2-1,nz1:nz2-1)
    open(1, file='v_c',recl=io, form='unformatted', access='direct', &
        status='replace')
      write(1,rec=1) (((v_c(j,k,l),j=nx1,nx2-1),k=ny1,ny2-1),l=nz1,nz2-1)  
  close(1)
  
  
    
    E_IO = PVD_INI_XML('example.pvd',cf)
  do i = 1, 5
    time = (i-1)*0.425
    step = i
    v_R2 = v_R * i*i

  write(str , fmt) step
  E_IO = VTK_INI_XML(output_format='ascii',filename='XML_STRG'//trim(str)//'.vts',mesh_topology='StructuredGrid',&
                     nx1=nx1,nx2=nx2,ny1=ny1,ny2=ny2,nz1=nz1,nz2=nz2)
  E_IO = VTK_GEO_XML(nx1=nx1,nx2=nx2,ny1=ny1,ny2=ny2,nz1=nz1,nz2=nz2,NN=nn,X=x,Y=y,Z=z)
  
  
! bug here: no matter how many field requiring to write out, the order should be 
! 1. VTK_DAT_XML(... OPEN) WRTIE <pointdata> header 
! 2. VTK_VAR_XML( FIELD1)
! 3. VTK_VAR_XML( FIELD2)
! 4. ...
! 5. VTK_DAT_XML(... CLOSE)  write </pointdata>
! wrong case ------
!  do j = 1,5 
!  write(str2,fmt) j
!  E_IO = VTK_DAT_XML(var_location='node',var_block_action='open')
!  E_IO = VTK_VAR_XML(NC_NN=nn,varname='scal_'//str2,var=v_R2)
!  E_IO = VTK_DAT_XML(var_location='node',var_block_action='close')
!  end do
! wrong case ------


!  E_IO = VTK_DAT_XML(var_location='node',var_block_action='open')
!  E_IO = VTK_VAR_XML(NC_NN=nn,varname='vect_R8',varX=v_R2,varY=v_R,varZ=v_R2)
!  E_IO = VTK_DAT_XML(var_location='node',var_block_action='close')
  
!  E_IO = VTK_DAT_XML(var_location='cell',var_block_action='open')
!  E_IO = VTK_VAR_XML(NC_NN=nc,varname='cell_R8',var=v_c)
!  E_IO = VTK_DAT_XML(var_location='cell',var_block_action='close')  
  
  E_IO = VTK_GEO_XML()
  
  E_IO=VTK_FLD_XML(fld_action='open')
  E_IO=VTK_FLD_XML(fld=time,fname='TIME')
  E_IO=VTK_FLD_XML(fld=step,fname='CYCLE')
  E_IO=VTK_FLD_XML(fld_action='close')
  E_IO = VTK_END_XML()
  
  
  E_IO = PVD_DAT_XML(filename='XML_STRG'//trim(str)//'.vts',timestep=time,cf=cf)
  end do
  E_IO = PVD_END_XML(cf)

  
  return
end program