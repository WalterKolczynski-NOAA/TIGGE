! Copyright 2005-2014 ECMWF.
!
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! 
! In applying this licence, ECMWF does not waive the privileges and immunities granted to it by
! virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.
!
!
!  Description: How to decode grib messages containing multiple
!               fields. Try to turn on and off multi support to
!               see the difference. Default is OFF.
!               For all the tools default is multi support ON.
!
!
!
!
program multi
  use grib_api
  implicit none
  
  integer              :: iret
  character(len = 256) :: error
  integer(kind = 4)    :: step
  integer              :: ifile,igrib

  call grib_open_file(ifile, '../../data/multi_created.grib2','r')

  !     turn on support for multi fields messages */
  call grib_multi_support_on()

  !     turn off support for multi fields messages */
  !call grib_multi_support_off()

  call grib_new_from_file(ifile,igrib, iret)
  !     Loop on all the messages in a file.

  write(*,*) 'step'
  do while (iret /= GRIB_END_OF_FILE)

     call grib_get(igrib,'step', step)
     write(*,'(i3)') step
     
     call grib_new_from_file(ifile,igrib, iret)
  
  end do
  call grib_close_file(ifile)

end program multi

