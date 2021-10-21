program example1

use Lib_VTK_IO


implicit none
  integer, parameter::   nx1=0,nx2=2,ny1=0,ny2=1,nz1=0,nz2=1
  integer, parameter::   nn=(nx2-nx1+1)*(ny2-ny1+1)*(nz2-nz1+1)
  real, dimension(nx1:nx2,ny1:ny2,nz1:nz2):: x,y,z
  real, dimension(nx1:nx2,ny1:ny2,nz1:nz2):: v_R, v_R2
  integer::                                  E_IO
  integer::                                  i,j,k, cf, step
  real :: time
  CHARACTER(LEN=15) :: str
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
    E_IO = PVD_INI_XML('example.pvd',cf)
  do i = 1, 10
    time = (i-1)*0.425
    step = i
    v_R2 = v_R * i*i

  write(str , fmt) step
  E_IO = VTK_INI_XML(output_format='binary',filename='XML_STRG'//trim(str)//'.vts',mesh_topology='StructuredGrid',&
                     nx1=nx1,nx2=nx2,ny1=ny1,ny2=ny2,nz1=nz1,nz2=nz2)
  E_IO = VTK_GEO_XML(nx1=nx1,nx2=nx2,ny1=ny1,ny2=ny2,nz1=nz1,nz2=nz2,NN=nn,X=x,Y=y,Z=z)
  E_IO = VTK_DAT_XML(var_location='node',var_block_action='open')
  E_IO = VTK_VAR_XML(NC_NN=nn,varname='scal_R8',var=v_R2)
  E_IO = VTK_DAT_XML(var_location='node',var_block_action='close')
  
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