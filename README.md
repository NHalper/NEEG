# NEEG
NEEG or MCM (Multi-Camera Monitor) is an application for synchronizing up to 16 cameras with Blackrock's data acquisition systems and neural data files. It includes tools for scheduling and managing recordings, reviewing files, and marking custom events in reviewed files.

It is dependent on the GUI Layout Toolbox which can be found on Mathworks website: https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox

It was originally built using 2.1.2, so this may be the safest version to use to avoid compatibility issues. Version 2.1.2 does use MATLABs newer graphics system, so it should be stable for quite awhile.

NEEG/MCM depends on communication with Blackrock's Central Suite through the use of cbMEX, but cbMEX is version dependent, thus this program will need to utilize the version of cbMEX that matches the current central suite. This was last compiled with version 6.05.04, so it is known to be compatible with that. Blackrock moved to version 7, which may cause issues with compatibility since they added new methods of indexing input and output channels.

NEEG/MCM may work with any cameras that Support direct show, but it was designed to work with the Euresys video capture cards and QSEE analog coaxial cameras.

Additionally, this software is dependent on Blackrock's NPMK (Neural Processing Matlab Kit), for convenience, I have uploaded a 'frozen' version of the NPMK that tested well with MCM.
