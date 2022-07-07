/*	getError(SystemErrorCode) 
Adapted from:
	https://www.codeproject.com/reference/800546/windows-system-error-codes
*/

getError(SystemErrorCode)
{
	if SystemErrorCode == 0x0		
		return "The operation completed successfully."
	else if SystemErrorCode == 0x1		
		return "Incorrect function."
	else if SystemErrorCode == 0x2		
		return "The system cannot find the file specified."
	else if SystemErrorCode == 0x3		
		return "The system cannot find the path specified."
	else if SystemErrorCode == 0x4		
		return "The system cannot open the file."
	else if SystemErrorCode == 0x5		
		return "Access is denied."
	else if SystemErrorCode == 0x6		
		return "The handle is invalid."
	else if SystemErrorCode == 0x7		
		return "The storage control blocks were destroyed."
	else if SystemErrorCode == 0x8		
		return "Not enough storage is available to process this command."
	else if SystemErrorCode == 0x9		
		return "The storage control block address is invalid."
	else if SystemErrorCode == 0xA		
		return "The environment is incorrect."
	else if SystemErrorCode == 0xB		
		return "An attempt was made to load a program with an incorrect format."
	else if SystemErrorCode == 0xC		
		return "The access code is invalid."
	else if SystemErrorCode == 0xD		
		return "The data is invalid."
	else if SystemErrorCode == 0xE		
		return "Not enough storage is available to complete this operation."
	else if SystemErrorCode == 0xF		
		return "The system cannot find the drive specified."
	else if SystemErrorCode == 0x10		
		return "The directory cannot be removed."
	else if SystemErrorCode == 0x11		
		return "The system cannot move the file to a different disk drive."
	else if SystemErrorCode == 0x12		
		return "There are no more files."
	else if SystemErrorCode == 0x13		
		return "The media is write protected."
	else if SystemErrorCode == 0x14		
		return "The system cannot find the device specified."
	else if SystemErrorCode == 0x15		
		return "The device is not ready."
	else if SystemErrorCode == 0x16		
		return "The device does not recognize the command."
	else if SystemErrorCode == 0x18		
		return "The program issued a command but the command length is incorrect."
	else if SystemErrorCode == 0x19		
		return "The drive cannot locate a specific area or track on the disk."
	else if SystemErrorCode == 0x1A		
		return "The specified disk or diskette cannot be accessed."
	else if SystemErrorCode == 0x1B		
		return "The drive cannot find the sector requested."
	else if SystemErrorCode == 0x1C		
		return "The printer is out of paper."
	else if SystemErrorCode == 0x1D		
		return "The system cannot write to the specified device."
	else if SystemErrorCode == 0x1E		
		return "The system cannot read from the specified device."
	else if SystemErrorCode == 0x1F		
		return "A device attached to the system is not functioning."
	else if SystemErrorCode == 0x20		
		return "The process cannot access the file because it is being used by another process."
	else if SystemErrorCode == 0x21		
		return "The process cannot access the file because another process has locked a portion of the file."
	else if SystemErrorCode == 0x24		
		return "Too many files opened for sharing."
	else if SystemErrorCode == 0x26		
		return "Reached the end of the file."
	else if SystemErrorCode == 0x27		
		return "The disk is full."
	else if SystemErrorCode == 0x32		
		return "The request is not supported."
	else if SystemErrorCode == 0x35		
		return "The network path was not found."
	else if SystemErrorCode == 0x36		
		return "The network is busy."
	else if SystemErrorCode == 0x37		
		return "The specified network resource or device is no longer available."
	else if SystemErrorCode == 0x38		
		return "The network BIOS command limit has been reached."
	else if SystemErrorCode == 0x39		
		return "A network adapter hardware error occurred."
	else if SystemErrorCode == 0x3A		
		return "The specified server cannot perform the requested operation."
	else if SystemErrorCode == 0x3B		
		return "An unexpected network error occurred."
	else if SystemErrorCode == 0x3C		
		return "The remote adapter is not compatible."
	else if SystemErrorCode == 0x3D		
		return "The printer queue is full."
	else if SystemErrorCode == 0x3E		
		return "Space to store the file waiting to be printed is not available on the server."
	else if SystemErrorCode == 0x3F		
		return "Your file waiting to be printed was deleted."
	else if SystemErrorCode == 0x40		
		return "The specified network name is no longer available."
	else if SystemErrorCode == 0x41		
		return "Network access is denied."
	else if SystemErrorCode == 0x42		
		return "The network resource type is not correct."
	else if SystemErrorCode == 0x43		
		return "The network name cannot be found."
	else if SystemErrorCode == 0x44		
		return "The name limit for the local computer network adapter card was exceeded."
	else if SystemErrorCode == 0x45		
		return "The network BIOS session limit was exceeded."
	else if SystemErrorCode == 0x46		
		return "The remote server has been paused or is in the process of being started."
	else if SystemErrorCode == 0x47		
		return "No more connections can be made to this remote computer at this time because there are already as many connections as the computer can accept."
	else if SystemErrorCode == 0x48		
		return "The specified printer or disk device has been paused."
	else if SystemErrorCode == 0x50		
		return "The file exists."
	else if SystemErrorCode == 0x52		
		return "The directory or file cannot be created."
	else if SystemErrorCode == 0x53		
		return "Fail on INT 24."
	else if SystemErrorCode == 0x54		
		return "Storage to process this request is not available."
	else if SystemErrorCode == 0x55		
		return "The local device name is already in use."
	else if SystemErrorCode == 0x56		
		return "The specified network password is not correct."
	else if SystemErrorCode == 0x57		
		return "The parameter is incorrect."
	else if SystemErrorCode == 0x58		
		return "A write fault occurred on the network."
	else if SystemErrorCode == 0x59		
		return "The system cannot start another process at this time."
	else if SystemErrorCode == 0x64		
		return "Cannot create another system semaphore."
	else if SystemErrorCode == 0x65		
		return "The exclusive semaphore is owned by another process."
	else if SystemErrorCode == 0x66		
		return "The semaphore is set and cannot be closed."
	else if SystemErrorCode == 0x67		
		return "The semaphore cannot be set again."
	else if SystemErrorCode == 0x68		
		return "Cannot request exclusive semaphores at interrupt time."
	else if SystemErrorCode == 0x69		
		return "The previous ownership of this semaphore has ended."
	else if SystemErrorCode == 0x6B		
		return "The program stopped because an alternate diskette was not inserted."
	else if SystemErrorCode == 0x6C		
		return "The disk is in use or locked by another process."
	else if SystemErrorCode == 0x6D		
		return "The pipe has been ended."
	else if SystemErrorCode == 0x6E		
		return "The system cannot open the device or file specified."
	else if SystemErrorCode == 0x6F		
		return "The file name is too long."
	else if SystemErrorCode == 0x70		
		return "There is not enough space on the disk."
	else if SystemErrorCode == 0x71		
		return "No more internal file identifiers available."
	else if SystemErrorCode == 0x72		
		return "The target internal file identifier is incorrect."
	else if SystemErrorCode == 0x75		
		return "The IOCTL call made by the application program is not correct."
	else if SystemErrorCode == 0x77		
		return "The system does not support the command requested."
	else if SystemErrorCode == 0x78		
		return "This function is not supported on this system."
	else if SystemErrorCode == 0x79		
		return "The semaphore timeout period has expired."
	else if SystemErrorCode == 0x7A		
		return "The data area passed to a system call is too small."
	else if SystemErrorCode == 0x7C		
		return "The system call level is not correct."
	else if SystemErrorCode == 0x7D		
		return "The disk has no volume label."
	else if SystemErrorCode == 0x7E		
		return "The specified module could not be found."
	else if SystemErrorCode == 0x7F		
		return "The specified procedure could not be found."
	else if SystemErrorCode == 0x80		
		return "There are no child processes to wait for."
	else if SystemErrorCode == 0x83		
		return "An attempt was made to move the file pointer before the beginning of the file."
	else if SystemErrorCode == 0x84		
		return "The file pointer cannot be set on the specified device or file."
	else if SystemErrorCode == 0x85		
		return "A JOIN or SUBST command cannot be used for a drive that contains previously joined drives."
	else if SystemErrorCode == 0x86		
		return "An attempt was made to use a JOIN or SUBST command on a drive that has already been joined."
	else if SystemErrorCode == 0x87		
		return "An attempt was made to use a JOIN or SUBST command on a drive that has already been substituted."
	else if SystemErrorCode == 0x88		
		return "The system tried to delete the JOIN of a drive that is not joined."
	else if SystemErrorCode == 0x89		
		return "The system tried to delete the substitution of a drive that is not substituted."
	else if SystemErrorCode == 0x8A		
		return "The system tried to join a drive to a directory on a joined drive."
	else if SystemErrorCode == 0x8B		
		return "The system tried to substitute a drive to a directory on a substituted drive."
	else if SystemErrorCode == 0x8C		
		return "The system tried to join a drive to a directory on a substituted drive."
	else if SystemErrorCode == 0x8D		
		return "The system tried to SUBST a drive to a directory on a joined drive."
	else if SystemErrorCode == 0x8E		
		return "The system cannot perform a JOIN or SUBST at this time."
	else if SystemErrorCode == 0x8F		
		return "The system cannot join or substitute a drive to or for a directory on the same drive."
	else if SystemErrorCode == 0x90		
		return "The directory is not a subdirectory of the root directory."
	else if SystemErrorCode == 0x91		
		return "The directory is not empty."
	else if SystemErrorCode == 0x92		
		return "The path specified is being used in a substitute."
	else if SystemErrorCode == 0x93		
		return "Not enough resources are available to process this command."
	else if SystemErrorCode == 0x94		
		return "The path specified cannot be used at this time."
	else if SystemErrorCode == 0x95		
		return "An attempt was made to join or substitute a drive for which a directory on the drive is the target of a previous substitute."
	else if SystemErrorCode == 0x97		
		return "The number of specified semaphore events for DosMuxSemWait is not correct."
	else if SystemErrorCode == 0x99		
		return "The DosMuxSemWait list is not correct."
	else if SystemErrorCode == 0x9A		
		return "The volume label you entered exceeds the label character limit of the target file system."
	else if SystemErrorCode == 0x9B		
		return "Cannot create another thread."
	else if SystemErrorCode == 0x9C		
		return "The recipient process has refused the signal."
	else if SystemErrorCode == 0x9D		
		return "The segment is already discarded and cannot be locked."
	else if SystemErrorCode == 0x9E		
		return "The segment is already unlocked."
	else if SystemErrorCode == 0x9F		
		return "The address for the thread ID is not correct."
	else if SystemErrorCode == 0xA0		
		return "One or more arguments are not correct."
	else if SystemErrorCode == 0xA1		
		return "The specified path is invalid."
	else if SystemErrorCode == 0xA2		
		return "A signal is already pending."
	else if SystemErrorCode == 0xA4		
		return "No more threads can be created in the system."
	else if SystemErrorCode == 0xA7		
		return "Unable to lock a region of a file."
	else if SystemErrorCode == 0xAA		
		return "The requested resource is in use."
	else if SystemErrorCode == 0xAD		
		return "A lock request was not outstanding for the supplied cancel region."
	else if SystemErrorCode == 0xAE		
		return "The file system does not support atomic changes to the lock type."
	else if SystemErrorCode == 0xB4		
		return "The system detected a segment number that was not correct."
	else if SystemErrorCode == 0xB7		
		return "Cannot create a file when that file already exists."
	else if SystemErrorCode == 0xBA		
		return "The flag passed is not correct."
	else if SystemErrorCode == 0xBB		
		return "The specified system semaphore name was not found."
	else if SystemErrorCode == 0xC4		
		return "The operating system cannot run this application program."
	else if SystemErrorCode == 0xC5		
		return "The operating system is not presently configured to run this application."
	else if SystemErrorCode == 0xC7		
		return "The operating system cannot run this application program."
	else if SystemErrorCode == 0xC8		
		return "The code segment cannot be greater than or equal to 64K."
	else if SystemErrorCode == 0xCB		
		return "The system could not find the environment option that was entered."
	else if SystemErrorCode == 0xCD		
		return "No process in the command subtree has a signal handler."
	else if SystemErrorCode == 0xCE		
		return "The filename or extension is too long."
	else if SystemErrorCode == 0xCF		
		return "The ring 2 stack is in use."
	else if SystemErrorCode == 0xD1		
		return "The signal being posted is not correct."
	else if SystemErrorCode == 0xD2		
		return "The signal handler cannot be set."
	else if SystemErrorCode == 0xD4		
		return "The segment is locked and cannot be reallocated."
	else if SystemErrorCode == 0xD7		
		return "Cannot nest calls to LoadModule."
	else if SystemErrorCode == 0xDC		
		return "This file is checked out or locked for editing by another user."
	else if SystemErrorCode == 0xDD		
		return "The file must be checked out before saving changes."
	else if SystemErrorCode == 0xDE		
		return "The file type being saved or retrieved has been blocked."
	else if SystemErrorCode == 0xDF		
		return "The file size exceeds the limit allowed and cannot be saved."
	else if SystemErrorCode == 0xE1		
		return "Operation did not complete successfully because the file contains a virus or potentially unwanted software."
	else if SystemErrorCode == 0xE5		
		return "The pipe is local."
	else if SystemErrorCode == 0xE6		
		return "The pipe state is invalid."
	else if SystemErrorCode == 0xE7		
		return "All pipe instances are busy."
	else if SystemErrorCode == 0xE8		
		return "The pipe is being closed."
	else if SystemErrorCode == 0xE9		
		return "No process is on the other end of the pipe."
	else if SystemErrorCode == 0xEA		
		return "More data is available."
	else if SystemErrorCode == 0xF0		
		return "The session was canceled."
	else if SystemErrorCode == 0xFE		
		return "The specified extended attribute name was invalid."
	else if SystemErrorCode == 0xFF		
		return "The extended attributes are inconsistent."
	else if SystemErrorCode == 0x102		
		return "The wait operation timed out."
	else if SystemErrorCode == 0x103		
		return "No more data is available."
	else if SystemErrorCode == 0x10A		
		return "The copy functions cannot be used."
	else if SystemErrorCode == 0x10B		
		return "The directory name is invalid."
	else if SystemErrorCode == 0x113		
		return "The extended attributes did not fit in the buffer."
	else if SystemErrorCode == 0x114		
		return "The extended attribute file on the mounted file system is corrupt."
	else if SystemErrorCode == 0x115		
		return "The extended attribute table file is full."
	else if SystemErrorCode == 0x116		
		return "The specified extended attribute handle is invalid."
	else if SystemErrorCode == 0x11A		
		return "The mounted file system does not support extended attributes."
	else if SystemErrorCode == 0x120		
		return "Attempt to release mutex not owned by caller."
	else if SystemErrorCode == 0x12A		
		return "Too many posts were made to a semaphore."
	else if SystemErrorCode == 0x12B		
		return "Only part of a ReadProcessMemory or WriteProcessMemory request was completed."
	else if SystemErrorCode == 0x12C		
		return "The oplock request is denied."
	else if SystemErrorCode == 0x12D		
		return "An invalid oplock acknowledgment was received by the system."
	else if SystemErrorCode == 0x12E		
		return "The volume is too fragmented to complete this operation."
	else if SystemErrorCode == 0x12F		
		return "The file cannot be opened because it is in the process of being deleted."
	else if SystemErrorCode == 0x130		
		return "Short name settings may not be changed on this volume due to the global registry setting."
	else if SystemErrorCode == 0x131		
		return "Short names are not enabled on this volume."
	else if SystemErrorCode == 0x132		
		return "The security stream for the given volume is in an inconsistent state. Please run CHKDSK on the volume."
	else if SystemErrorCode == 0x133		
		return "A requested file lock operation cannot be processed due to an invalid byte range."
	else if SystemErrorCode == 0x134		
		return "The subsystem needed to support the image type is not present."
	else if SystemErrorCode == 0x135		
		return "The specified file already has a notification GUID associated with it."
	else if SystemErrorCode == 0x136		
		return "An invalid exception handler routine has been detected."
	else if SystemErrorCode == 0x137		
		return "Duplicate privileges were specified for the token."
	else if SystemErrorCode == 0x138		
		return "No ranges for the specified operation were able to be processed."
	else if SystemErrorCode == 0x139		
		return "Operation is not allowed on a file system internal file."
	else if SystemErrorCode == 0x13A		
		return "The physical resources of this disk have been exhausted."
	else if SystemErrorCode == 0x13B		
		return "The token representing the data is invalid."
	else if SystemErrorCode == 0x13C		
		return "The device does not support the command feature."
	else if SystemErrorCode == 0x13E		
		return "The scope specified was not found."
	else if SystemErrorCode == 0x13F		
		return "The Central Access Policy specified is not defined on the target machine."
	else if SystemErrorCode == 0x140		
		return "The Central Access Policy obtained from Active Directory is invalid."
	else if SystemErrorCode == 0x141		
		return "The device is unreachable."
	else if SystemErrorCode == 0x142		
		return "The target device has insufficient resources to complete the operation."
	else if SystemErrorCode == 0x143		
		return "A data integrity checksum error occurred. Data in the file stream is corrupt."
	else if SystemErrorCode == 0x148		
		return "The command specified an invalid field in its parameter list."
	else if SystemErrorCode == 0x149		
		return "An operation is currently in progress with the device."
	else if SystemErrorCode == 0x14A		
		return "An attempt was made to send down the command via an invalid path to the target device."
	else if SystemErrorCode == 0x14B		
		return "The command specified a number of descriptors that exceeded the maximum supported by the device."
	else if SystemErrorCode == 0x14C		
		return "Scrub is disabled on the specified file."
	else if SystemErrorCode == 0x14D		
		return "The storage device does not provide redundancy."
	else if SystemErrorCode == 0x14E		
		return "An operation is not supported on a resident file."
	else if SystemErrorCode == 0x14F		
		return "An operation is not supported on a compressed file."
	else if SystemErrorCode == 0x150		
		return "An operation is not supported on a directory."
	else if SystemErrorCode == 0x151		
		return "The specified copy of the requested data could not be read."
	else if SystemErrorCode == 0x15E		
		return "No action was taken as a system reboot is required."
	else if SystemErrorCode == 0x15F		
		return "The shutdown operation failed."
	else if SystemErrorCode == 0x160		
		return "The restart operation failed."
	else if SystemErrorCode == 0x161		
		return "The maximum number of sessions has been reached."
	else if SystemErrorCode == 0x190		
		return "The thread is already in background processing mode."
	else if SystemErrorCode == 0x191		
		return "The thread is not in background processing mode."
	else if SystemErrorCode == 0x192		
		return "The process is already in background processing mode."
	else if SystemErrorCode == 0x193		
		return "The process is not in background processing mode."
	else if SystemErrorCode == 0x1E7		
		return "Attempt to access invalid address."
	else if SystemErrorCode == 0x1F4		
		return "User profile cannot be loaded."
	else if SystemErrorCode == 0x216		
		return "Arithmetic result exceeded 32 bits."
	else if SystemErrorCode == 0x217		
		return "There is a process on other end of the pipe."
	else if SystemErrorCode == 0x218		
		return "Waiting for a process to open the other end of the pipe."
	else if SystemErrorCode == 0x219		
		return "Application verifier has found an error in the current process."
	else if SystemErrorCode == 0x21A		
		return "An error occurred in the ABIOS subsystem."
	else if SystemErrorCode == 0x21B		
		return "A warning occurred in the WX86 subsystem."
	else if SystemErrorCode == 0x21C		
		return "An error occurred in the WX86 subsystem."
	else if SystemErrorCode == 0x21D		
		return "An attempt was made to cancel or set a timer that has an associated APC and the subject thread is not the thread that originally set the timer with an associated APC routine."
	else if SystemErrorCode == 0x21E		
		return "Unwind exception code."
	else if SystemErrorCode == 0x21F		
		return "An invalid or unaligned stack was encountered during an unwind operation."
	else if SystemErrorCode == 0x220		
		return "An invalid unwind target was encountered during an unwind operation."
	else if SystemErrorCode == 0x221		
		return "Invalid Object Attributes specified to NtCreatePort or invalid Port Attributes specified to NtConnectPort"
	else if SystemErrorCode == 0x222		
		return "Length of message passed to NtRequestPort or NtRequestWaitReplyPort was longer than the maximum message allowed by the port."
	else if SystemErrorCode == 0x223		
		return "An attempt was made to lower a quota limit below the current usage."
	else if SystemErrorCode == 0x224		
		return "An attempt was made to attach to a device that was already attached to another device."
	else if SystemErrorCode == 0x225		
		return "An attempt was made to execute an instruction at an unaligned address and the host system does not support unaligned instruction references."
	else if SystemErrorCode == 0x226		
		return "Profiling not started."
	else if SystemErrorCode == 0x227		
		return "Profiling not stopped."
	else if SystemErrorCode == 0x228		
		return "The passed ACL did not contain the minimum required information."
	else if SystemErrorCode == 0x229		
		return "The number of active profiling objects is at the maximum and no more may be started."
	else if SystemErrorCode == 0x22F		
		return "A malformed function table was encountered during an unwind operation."
	else if SystemErrorCode == 0x233		
		return "Indicates that the starting value for the LDT information was not an integral multiple of the selector size."
	else if SystemErrorCode == 0x234		
		return "Indicates that the user supplied an invalid descriptor when trying to set up Ldt descriptors."
	else if SystemErrorCode == 0x237		
		return "Page file quota was exceeded."
	else if SystemErrorCode == 0x238		
		return "The Netlogon service cannot start because another Netlogon service running in the domain conflicts with the specified role."
	else if SystemErrorCode == 0x239		
		return "The SAM database on a Windows Server is significantly out of synchronization with the copy on the Domain Controller. A complete synchronization is required."
	else if SystemErrorCode == 0x245		
		return "A Windows Server has an incorrect configuration."
	else if SystemErrorCode == 0x247		
		return "The Unicode character is not defined in the Unicode character set installed on the system."
	else if SystemErrorCode == 0x248		
		return "The paging file cannot be created on a floppy diskette."
	else if SystemErrorCode == 0x249		
		return "The system BIOS failed to connect a system interrupt to the device or bus for which the device is connected."
	else if SystemErrorCode == 0x24A		
		return "This operation is only allowed for the Primary Domain Controller of the domain."
	else if SystemErrorCode == 0x24B		
		return "An attempt was made to acquire a mutant such that its maximum count would have been exceeded."
	else if SystemErrorCode == 0x24C		
		return "A volume has been accessed for which a file system driver is required that has not yet been loaded."
	else if SystemErrorCode == 0x251		
		return "NTVDM encountered a hard error."
	else if SystemErrorCode == 0x256		
		return "The stream is not a tiny stream."
	else if SystemErrorCode == 0x257		
		return "The request must be handled by the stack overflow code."
	else if SystemErrorCode == 0x258		
		return "Internal OFS status codes indicating how an allocation operation is handled. Either it is retried after the containing onode is moved or the extent stream is converted to a large stream."
	else if SystemErrorCode == 0x259		
		return "The attempt to find the object found an object matching by ID on the volume but it is out of the scope of the handle used for the operation."
	else if SystemErrorCode == 0x25A		
		return "The bucket array must be grown. Retry transaction after doing so."
	else if SystemErrorCode == 0x25C		
		return "The supplied variant structure contains invalid data."
	else if SystemErrorCode == 0x25F		
		return "The timer resolution was not previously set by the current process."
	else if SystemErrorCode == 0x260		
		return "There is insufficient account information to log you on."
	else if SystemErrorCode == 0x263		
		return "There is an IP address conflict with another system on the network."
	else if SystemErrorCode == 0x264		
		return "There is an IP address conflict with another system on the network."
	else if SystemErrorCode == 0x266		
		return "A callback return system service cannot be executed when no callback is active."
	else if SystemErrorCode == 0x267		
		return "The password provided is too short to meet the policy of your user account. Please choose a longer password."
	else if SystemErrorCode == 0x269		
		return "You have attempted to change your password to one that you have used in the past. The policy of your user account does not allow this. Please select a password that you have not previously used."
	else if SystemErrorCode == 0x26A		
		return "The specified compression format is unsupported."
	else if SystemErrorCode == 0x26B		
		return "The specified hardware profile configuration is invalid."
	else if SystemErrorCode == 0x26C		
		return "The specified Plug and Play registry device path is invalid."
	else if SystemErrorCode == 0x26D		
		return "The specified quota list is internally inconsistent with its descriptor."
	else if SystemErrorCode == 0x271		
		return "The validation process needs to continue on to the next step."
	else if SystemErrorCode == 0x272		
		return "There are no more matches for the current index enumeration."
	else if SystemErrorCode == 0x273		
		return "The range could not be added to the range list because of a conflict."
	else if SystemErrorCode == 0x274		
		return "The server process is running under a SID different than that required by client."
	else if SystemErrorCode == 0x275		
		return "A group marked use for deny only cannot be enabled."
	else if SystemErrorCode == 0x278		
		return "The requested interface is not supported."
	else if SystemErrorCode == 0x27C		
		return "A device was removed so enumeration must be restarted."
	else if SystemErrorCode == 0x27E		
		return "Device will not start without a reboot."
	else if SystemErrorCode == 0x27F		
		return "There is not enough power to complete the requested operation."
	else if SystemErrorCode == 0x280		
		return "ERROR_MULTIPLE_FAULT_VIOLATION"
	else if SystemErrorCode == 0x281		
		return "The system is in the process of shutting down."
	else if SystemErrorCode == 0x284		
		return "The specified range could not be found in the range list."
	else if SystemErrorCode == 0x286		
		return "The driver was not loaded because the system is booting into safe mode."
	else if SystemErrorCode == 0x287		
		return "The driver was not loaded because it failed its initialization call."
	else if SystemErrorCode == 0x289		
		return "The create operation failed because the name contained at least one mount point which resolves to a volume to which the specified device object is not attached."
	else if SystemErrorCode == 0x28A		
		return "The device object parameter is either not a valid device object or is not attached to the volume specified by the file name."
	else if SystemErrorCode == 0x28B		
		return "A Machine Check Error has occurred. Please check the system eventlog for additional information."
	else if SystemErrorCode == 0x28D		
		return "System hive size has exceeded its limit."
	else if SystemErrorCode == 0x28E		
		return "The driver could not be loaded because a previous version of the driver is still in memory."
	else if SystemErrorCode == 0x291		
		return "The password provided is too long to meet the policy of your user account. Please choose a shorter password."
	else if SystemErrorCode == 0x299		
		return "The requested operation could not be completed due to a file system limitation."
	else if SystemErrorCode == 0x29C		
		return "An assertion failure has occurred."
	else if SystemErrorCode == 0x29D		
		return "An error occurred in the ACPI subsystem."
	else if SystemErrorCode == 0x29E		
		return "WOW Assertion Error."
	else if SystemErrorCode == 0x29F		
		return "A device is missing in the system BIOS MPS table. This device will not be used. Please contact your system vendor for system BIOS update."
	else if SystemErrorCode == 0x2A0		
		return "A translator failed to translate resources."
	else if SystemErrorCode == 0x2A1		
		return "A IRQ translator failed to translate resources."
	else if SystemErrorCode == 0x2A9		
		return "The create operation stopped after reaching a symbolic link."
	else if SystemErrorCode == 0x2AA		
		return "A long jump has been executed."
	else if SystemErrorCode == 0x2AB		
		return "The Plug and Play query operation was not successful."
	else if SystemErrorCode == 0x2AC		
		return "A frame consolidation has been executed."
	else if SystemErrorCode == 0x2B0		
		return "Debugger did not handle the exception."
	else if SystemErrorCode == 0x2B1		
		return "Debugger will reply later."
	else if SystemErrorCode == 0x2B2		
		return "Debugger cannot provide handle."
	else if SystemErrorCode == 0x2B3		
		return "Debugger terminated thread."
	else if SystemErrorCode == 0x2B4		
		return "Debugger terminated process."
	else if SystemErrorCode == 0x2B5		
		return "Debugger got control C."
	else if SystemErrorCode == 0x2B6		
		return "Debugger printed exception on control C."
	else if SystemErrorCode == 0x2B7		
		return "Debugger received RIP exception."
	else if SystemErrorCode == 0x2B8		
		return "Debugger received control break."
	else if SystemErrorCode == 0x2B9		
		return "Debugger command communication exception."
	else if SystemErrorCode == 0x2CA		
		return "The specified registry key is referenced by a predefined handle."
	else if SystemErrorCode == 0x2CF		
		return "ERROR_ALREADY_WIN32"
	else if SystemErrorCode == 0x2D1		
		return "A yield execution was performed and no thread was available to run."
	else if SystemErrorCode == 0x2D2		
		return "The resumable flag to a timer API was ignored."
	else if SystemErrorCode == 0x2D3		
		return "The arbiter has deferred arbitration of these resources to its parent."
	else if SystemErrorCode == 0x2D6		
		return "The system was put into hibernation."
	else if SystemErrorCode == 0x2D7		
		return "The system was resumed from hibernation."
	else if SystemErrorCode == 0x2DA		
		return "The system has awoken."
	else if SystemErrorCode == 0x2DB		
		return "ERROR_WAIT_1"
	else if SystemErrorCode == 0x2DC		
		return "ERROR_WAIT_2"
	else if SystemErrorCode == 0x2DD		
		return "ERROR_WAIT_3"
	else if SystemErrorCode == 0x2DE		
		return "ERROR_WAIT_63"
	else if SystemErrorCode == 0x2DF		
		return "ERROR_ABANDONED_WAIT_0"
	else if SystemErrorCode == 0x2E0		
		return "ERROR_ABANDONED_WAIT_63"
	else if SystemErrorCode == 0x2E1		
		return "ERROR_USER_APC"
	else if SystemErrorCode == 0x2E2		
		return "ERROR_KERNEL_APC"
	else if SystemErrorCode == 0x2E3		
		return "ERROR_ALERTED"
	else if SystemErrorCode == 0x2E4		
		return "The requested operation requires elevation."
	else if SystemErrorCode == 0x2E5		
		return "A reparse should be performed by the Object Manager since the name of the file resulted in a symbolic link."
	else if SystemErrorCode == 0x2E7		
		return "A new volume has been mounted by a file system."
	else if SystemErrorCode == 0x2E9		
		return "This indicates that a notify change request has been completed due to closing the handle which made the notify change request."
	else if SystemErrorCode == 0x2EB		
		return "Page fault was a transition fault."
	else if SystemErrorCode == 0x2EC		
		return "Page fault was a demand zero fault."
	else if SystemErrorCode == 0x2ED		
		return "Page fault was a demand zero fault."
	else if SystemErrorCode == 0x2EE		
		return "Page fault was a demand zero fault."
	else if SystemErrorCode == 0x2EF		
		return "Page fault was satisfied by reading from a secondary storage device."
	else if SystemErrorCode == 0x2F0		
		return "Cached page was locked during operation."
	else if SystemErrorCode == 0x2F1		
		return "Crash dump exists in paging file."
	else if SystemErrorCode == 0x2F2		
		return "Specified buffer contains all zeros."
	else if SystemErrorCode == 0x2F3		
		return "A reparse should be performed by the Object Manager since the name of the file resulted in a symbolic link."
	else if SystemErrorCode == 0x2F5		
		return "The translator has translated these resources into the global space and no further translations should be performed."
	else if SystemErrorCode == 0x2F6		
		return "A process being terminated has no threads to terminate."
	else if SystemErrorCode == 0x2F7		
		return "The specified process is not part of a job."
	else if SystemErrorCode == 0x2F8		
		return "The specified process is part of a job."
	else if SystemErrorCode == 0x2FA		
		return "A file system or file system filter driver has successfully completed an FsFilter operation."
	else if SystemErrorCode == 0x2FB		
		return "The specified interrupt vector was already connected."
	else if SystemErrorCode == 0x2FC		
		return "The specified interrupt vector is still connected."
	else if SystemErrorCode == 0x2FD		
		return "An operation is blocked waiting for an oplock."
	else if SystemErrorCode == 0x2FE		
		return "Debugger handled exception."
	else if SystemErrorCode == 0x2FF		
		return "Debugger continued."
	else if SystemErrorCode == 0x300		
		return "An exception occurred in a user mode callback and the kernel callback frame should be removed."
	else if SystemErrorCode == 0x301		
		return "Compression is disabled for this volume."
	else if SystemErrorCode == 0x302		
		return "The data provider cannot fetch backwards through a result set."
	else if SystemErrorCode == 0x303		
		return "The data provider cannot scroll backwards through a result set."
	else if SystemErrorCode == 0x304		
		return "The data provider requires that previously fetched data is released before asking for more data."
	else if SystemErrorCode == 0x305		
		return "The data provider was not able to interpret the flags set for a column binding in an accessor."
	else if SystemErrorCode == 0x306		
		return "One or more errors occurred while processing the request."
	else if SystemErrorCode == 0x307		
		return "The implementation is not capable of performing the request."
	else if SystemErrorCode == 0x308		
		return "The client of a component requested an operation which is not valid given the state of the component instance."
	else if SystemErrorCode == 0x309		
		return "A version number could not be parsed."
	else if SystemErrorCode == 0x30B		
		return "The hardware has reported an uncorrectable memory error."
	else if SystemErrorCode == 0x30C		
		return "The attempted operation required self healing to be enabled."
	else if SystemErrorCode == 0x30D		
		return "The Desktop heap encountered an error while allocating session memory. There is more information in the system event log."
	else if SystemErrorCode == 0x310		
		return "A thread is getting dispatched with MCA EXCEPTION because of MCA."
	else if SystemErrorCode == 0x313		
		return "A valid hibernation file has been invalidated and should be abandoned."
	else if SystemErrorCode == 0x317		
		return "The resources required for this device conflict with the MCFG table."
	else if SystemErrorCode == 0x318		
		return "The volume repair could not be performed while it is online. Please schedule to take the volume offline so that it can be repaired."
	else if SystemErrorCode == 0x319		
		return "The volume repair was not successful."
	else if SystemErrorCode == 0x31B		
		return "One of the volume corruption logs is internally corrupted and needs to be recreated. The volume may contain undetected corruptions and must be scanned."
	else if SystemErrorCode == 0x31C		
		return "One of the volume corruption logs is unavailable for being operated on."
	else if SystemErrorCode == 0x31D		
		return "One of the volume corruption logs was deleted while still having corruption records in them. The volume contains detected corruptions and must be scanned."
	else if SystemErrorCode == 0x31E		
		return "One of the volume corruption logs was cleared by chkdsk and no longer contains real corruptions."
	else if SystemErrorCode == 0x31F		
		return "Orphaned files exist on the volume but could not be recovered because no more new names could be created in the recovery directory. Files must be moved from the recovery directory."
	else if SystemErrorCode == 0x320		
		return "The oplock that was associated with this handle is now associated with a different handle."
	else if SystemErrorCode == 0x321		
		return "An oplock of the requested level cannot be granted. An oplock of a lower level may be available."
	else if SystemErrorCode == 0x322		
		return "The operation did not complete successfully because it would cause an oplock to be broken. The caller has requested that existing oplocks not be broken."
	else if SystemErrorCode == 0x323		
		return "The handle with which this oplock was associated has been closed. The oplock is now broken."
	else if SystemErrorCode == 0x326		
		return "Access to the specified file handle has been revoked."
	else if SystemErrorCode == 0x327		
		return "An image file was mapped at a different address from the one specified in the image file but fixups will still be automatically performed on the image."
	else if SystemErrorCode == 0x3E2		
		return "Access to the extended attribute was denied."
	else if SystemErrorCode == 0x3E6		
		return "Invalid access to memory location."
	else if SystemErrorCode == 0x3E7		
		return "Error performing inpage operation."
	else if SystemErrorCode == 0x3EA		
		return "The window cannot act on the sent message."
	else if SystemErrorCode == 0x3EB		
		return "Cannot complete this function."
	else if SystemErrorCode == 0x3EC		
		return "Invalid flags."
	else if SystemErrorCode == 0x3ED		
		return "The volume does not contain a recognized file system. Please make sure that all required file system drivers are loaded and that the volume is not corrupted."
	else if SystemErrorCode == 0x3EE		
		return "The volume for a file has been externally altered so that the opened file is no longer valid."
	else if SystemErrorCode == 0x3F0		
		return "An attempt was made to reference a token that does not exist."
	else if SystemErrorCode == 0x3F1		
		return "The configuration registry database is corrupt."
	else if SystemErrorCode == 0x3F2		
		return "The configuration registry key is invalid."
	else if SystemErrorCode == 0x3F3		
		return "The configuration registry key could not be opened."
	else if SystemErrorCode == 0x3F4		
		return "The configuration registry key could not be read."
	else if SystemErrorCode == 0x3F5		
		return "The configuration registry key could not be written."
	else if SystemErrorCode == 0x3F6		
		return "One of the files in the registry database had to be recovered by use of a log or alternate copy. The recovery was successful."
	else if SystemErrorCode == 0x3FA		
		return "Illegal operation attempted on a registry key that has been marked for deletion."
	else if SystemErrorCode == 0x3FB		
		return "System could not allocate the required space in a registry log."
	else if SystemErrorCode == 0x3FC		
		return "Cannot create a symbolic link in a registry key that already has subkeys or values."
	else if SystemErrorCode == 0x3FD		
		return "Cannot create a stable subkey under a volatile parent key."
	else if SystemErrorCode == 0x41B		
		return "A stop control has been sent to a service that other running services are dependent on."
	else if SystemErrorCode == 0x41C		
		return "The requested control is not valid for this service."
	else if SystemErrorCode == 0x41D		
		return "The service did not respond to the start or control request in a timely fashion."
	else if SystemErrorCode == 0x41E		
		return "A thread could not be created for the service."
	else if SystemErrorCode == 0x41F		
		return "The service database is locked."
	else if SystemErrorCode == 0x420		
		return "An instance of the service is already running."
	else if SystemErrorCode == 0x423		
		return "Circular service dependency was specified."
	else if SystemErrorCode == 0x424		
		return "The specified service does not exist as an installed service."
	else if SystemErrorCode == 0x425		
		return "The service cannot accept control messages at this time."
	else if SystemErrorCode == 0x426		
		return "The service has not been started."
	else if SystemErrorCode == 0x427		
		return "The service process could not connect to the service controller."
	else if SystemErrorCode == 0x428		
		return "An exception occurred in the service when handling the control request."
	else if SystemErrorCode == 0x429		
		return "The database specified does not exist."
	else if SystemErrorCode == 0x42B		
		return "The process terminated unexpectedly."
	else if SystemErrorCode == 0x42C		
		return "The dependency service or group failed to start."
	else if SystemErrorCode == 0x42D		
		return "The service did not start due to a logon failure."
	else if SystemErrorCode == 0x42F		
		return "The specified service database lock is invalid."
	else if SystemErrorCode == 0x430		
		return "The specified service has been marked for deletion."
	else if SystemErrorCode == 0x431		
		return "The specified service already exists."
	else if SystemErrorCode == 0x433		
		return "The dependency service does not exist or has been marked for deletion."
	else if SystemErrorCode == 0x435		
		return "No attempts to start the service have been made since the last boot."
	else if SystemErrorCode == 0x436		
		return "The name is already in use as either a service name or a service display name."
	else if SystemErrorCode == 0x437		
		return "The account specified for this service is different from the account specified for other services running in the same process."
	else if SystemErrorCode == 0x43A		
		return "No recovery program has been configured for this service."
	else if SystemErrorCode == 0x43B		
		return "The executable program that this service is configured to run in does not implement the service."
	else if SystemErrorCode == 0x43C		
		return "This service cannot be started in Safe Mode."
	else if SystemErrorCode == 0x44C		
		return "The physical end of the tape has been reached."
	else if SystemErrorCode == 0x44D		
		return "A tape access reached a filemark."
	else if SystemErrorCode == 0x44E		
		return "The beginning of the tape or a partition was encountered."
	else if SystemErrorCode == 0x44F		
		return "A tape access reached the end of a set of files."
	else if SystemErrorCode == 0x450		
		return "No more data is on the tape."
	else if SystemErrorCode == 0x451		
		return "Tape could not be partitioned."
	else if SystemErrorCode == 0x453		
		return "Tape partition information could not be found when loading a tape."
	else if SystemErrorCode == 0x454		
		return "Unable to lock the media eject mechanism."
	else if SystemErrorCode == 0x455		
		return "Unable to unload the media."
	else if SystemErrorCode == 0x456		
		return "The media in the drive may have changed."
	else if SystemErrorCode == 0x458		
		return "No media in drive."
	else if SystemErrorCode == 0x45B		
		return "A system shutdown is in progress."
	else if SystemErrorCode == 0x45C		
		return "Unable to abort the system shutdown because no shutdown was in progress."
	else if SystemErrorCode == 0x45E		
		return "No serial device was successfully initialized. The serial driver will unload."
	else if SystemErrorCode == 0x462		
		return "No ID address mark was found on the floppy disk."
	else if SystemErrorCode == 0x463		
		return "Mismatch between the floppy disk sector ID field and the floppy disk controller track address."
	else if SystemErrorCode == 0x464		
		return "The floppy disk controller reported an error that is not recognized by the floppy disk driver."
	else if SystemErrorCode == 0x465		
		return "The floppy disk controller returned inconsistent results in its registers."
	else if SystemErrorCode == 0x469		
		return "Physical end of tape encountered."
	else if SystemErrorCode == 0x46A		
		return "Not enough server storage is available to process this command."
	else if SystemErrorCode == 0x46B		
		return "A potential deadlock condition has been detected."
	else if SystemErrorCode == 0x46C		
		return "The base address or the file offset specified does not have the proper alignment."
	else if SystemErrorCode == 0x474		
		return "An attempt to change the system power state was vetoed by another application or driver."
	else if SystemErrorCode == 0x475		
		return "The system BIOS failed an attempt to change the system power state."
	else if SystemErrorCode == 0x476		
		return "An attempt was made to create more links on a file than the file system supports."
	else if SystemErrorCode == 0x47E		
		return "The specified program requires a newer version of Windows."
	else if SystemErrorCode == 0x480		
		return "Cannot start more than one instance of the specified program."
	else if SystemErrorCode == 0x481		
		return "The specified program was written for an earlier version of Windows."
	else if SystemErrorCode == 0x482		
		return "One of the library files needed to run this application is damaged."
	else if SystemErrorCode == 0x483		
		return "No application is associated with the specified file for this operation."
	else if SystemErrorCode == 0x484		
		return "An error occurred in sending the command to the application."
	else if SystemErrorCode == 0x485		
		return "One of the library files needed to run this application cannot be found."
	else if SystemErrorCode == 0x486		
		return "The current process has used all of its system allowance of handles for Window Manager objects."
	else if SystemErrorCode == 0x487		
		return "The message can be used only with synchronous operations."
	else if SystemErrorCode == 0x488		
		return "The indicated source element has no media."
	else if SystemErrorCode == 0x489		
		return "The indicated destination element already contains media."
	else if SystemErrorCode == 0x48A		
		return "The indicated element does not exist."
	else if SystemErrorCode == 0x48B		
		return "The indicated element is part of a magazine that is not present."
	else if SystemErrorCode == 0x48C		
		return "The indicated device requires reinitialization due to hardware errors."
	else if SystemErrorCode == 0x48D		
		return "The device has indicated that cleaning is required before further operations are attempted."
	else if SystemErrorCode == 0x48E		
		return "The device has indicated that its door is open."
	else if SystemErrorCode == 0x48F		
		return "The device is not connected."
	else if SystemErrorCode == 0x490		
		return "Element not found."
	else if SystemErrorCode == 0x491		
		return "There was no match for the specified key in the index."
	else if SystemErrorCode == 0x492		
		return "The property set specified does not exist on the object."
	else if SystemErrorCode == 0x493		
		return "The point passed to GetMouseMovePoints is not in the buffer."
	else if SystemErrorCode == 0x495		
		return "The Volume ID could not be found."
	else if SystemErrorCode == 0x497		
		return "Unable to remove the file to be replaced."
	else if SystemErrorCode == 0x498		
		return "Unable to move the replacement file to the file to be replaced. The file to be replaced has retained its original name."
	else if SystemErrorCode == 0x499		
		return "Unable to move the replacement file to the file to be replaced. The file to be replaced has been renamed using the backup name."
	else if SystemErrorCode == 0x49A		
		return "The volume change journal is being deleted."
	else if SystemErrorCode == 0x49B		
		return "The volume change journal is not active."
	else if SystemErrorCode == 0x49D		
		return "The journal entry has been deleted from the journal."
	else if SystemErrorCode == 0x4A6		
		return "A system shutdown has already been scheduled."
	else if SystemErrorCode == 0x4A7		
		return "The system shutdown cannot be initiated because there are other users logged on to the computer."
	else if SystemErrorCode == 0x4B0		
		return "The specified device name is invalid."
	else if SystemErrorCode == 0x4B1		
		return "The device is not currently connected but it is a remembered connection."
	else if SystemErrorCode == 0x4B2		
		return "The local device name has a remembered connection to another network resource."
	else if SystemErrorCode == 0x4B4		
		return "The specified network provider name is invalid."
	else if SystemErrorCode == 0x4B5		
		return "Unable to open the network connection profile."
	else if SystemErrorCode == 0x4B6		
		return "The network connection profile is corrupted."
	else if SystemErrorCode == 0x4B7		
		return "Cannot enumerate a noncontainer."
	else if SystemErrorCode == 0x4B8		
		return "An extended error has occurred."
	else if SystemErrorCode == 0x4B9		
		return "The format of the specified group name is invalid."
	else if SystemErrorCode == 0x4BA		
		return "The format of the specified computer name is invalid."
	else if SystemErrorCode == 0x4BB		
		return "The format of the specified event name is invalid."
	else if SystemErrorCode == 0x4BC		
		return "The format of the specified domain name is invalid."
	else if SystemErrorCode == 0x4BD		
		return "The format of the specified service name is invalid."
	else if SystemErrorCode == 0x4BE		
		return "The format of the specified network name is invalid."
	else if SystemErrorCode == 0x4BF		
		return "The format of the specified share name is invalid."
	else if SystemErrorCode == 0x4C0		
		return "The format of the specified password is invalid."
	else if SystemErrorCode == 0x4C1		
		return "The format of the specified message name is invalid."
	else if SystemErrorCode == 0x4C2		
		return "The format of the specified message destination is invalid."
	else if SystemErrorCode == 0x4C5		
		return "The workgroup or domain name is already in use by another computer on the network."
	else if SystemErrorCode == 0x4C6		
		return "The network is not present or not started."
	else if SystemErrorCode == 0x4C7		
		return "The operation was canceled by the user."
	else if SystemErrorCode == 0x4C9		
		return "The remote computer refused the network connection."
	else if SystemErrorCode == 0x4CA		
		return "The network connection was gracefully closed."
	else if SystemErrorCode == 0x4CB		
		return "The network transport endpoint already has an address associated with it."
	else if SystemErrorCode == 0x4CC		
		return "An address has not yet been associated with the network endpoint."
	else if SystemErrorCode == 0x4CD		
		return "An operation was attempted on a nonexistent network connection."
	else if SystemErrorCode == 0x4CE		
		return "An invalid operation was attempted on an active network connection."
	else if SystemErrorCode == 0x4D2		
		return "No service is operating at the destination network endpoint on the remote system."
	else if SystemErrorCode == 0x4D3		
		return "The request was aborted."
	else if SystemErrorCode == 0x4D4		
		return "The network connection was aborted by the local system."
	else if SystemErrorCode == 0x4D5		
		return "The operation could not be completed. A retry should be performed."
	else if SystemErrorCode == 0x4D6		
		return "A connection to the server could not be made because the limit on the number of concurrent connections for this account has been reached."
	else if SystemErrorCode == 0x4D7		
		return "Attempting to log in during an unauthorized time of day for this account."
	else if SystemErrorCode == 0x4D8		
		return "The account is not authorized to log in from this station."
	else if SystemErrorCode == 0x4D9		
		return "The network address could not be used for the operation requested."
	else if SystemErrorCode == 0x4DA		
		return "The service is already registered."
	else if SystemErrorCode == 0x4DB		
		return "The specified service does not exist."
	else if SystemErrorCode == 0x4DC		
		return "The operation being requested was not performed because the user has not been authenticated."
	else if SystemErrorCode == 0x4DD		
		return "The operation being requested was not performed because the user has not logged on to the network. The specified service does not exist."
	else if SystemErrorCode == 0x4DE		
		return "Continue with work in progress."
	else if SystemErrorCode == 0x4DF		
		return "An attempt was made to perform an initialization operation when initialization has already been completed."
	else if SystemErrorCode == 0x4E0		
		return "No more local devices."
	else if SystemErrorCode == 0x4E1		
		return "The specified site does not exist."
	else if SystemErrorCode == 0x4E2		
		return "A domain controller with the specified name already exists."
	else if SystemErrorCode == 0x4E3		
		return "This operation is supported only when you are connected to the server."
	else if SystemErrorCode == 0x4E4		
		return "The group policy framework should call the extension even if there are no changes."
	else if SystemErrorCode == 0x4E5		
		return "The specified user does not have a valid profile."
	else if SystemErrorCode == 0x4E6		
		return "This operation is not supported on a computer running Windows Server 2003 for Small Business Server."
	else if SystemErrorCode == 0x4E7		
		return "The server machine is shutting down."
	else if SystemErrorCode == 0x4E9		
		return "The security identifier provided is not from an account domain."
	else if SystemErrorCode == 0x4EA		
		return "The security identifier provided does not have a domain component."
	else if SystemErrorCode == 0x4EB		
		return "AppHelp dialog canceled thus preventing the application from starting."
	else if SystemErrorCode == 0x4ED		
		return "A program attempt to use an invalid register value. Normally caused by an uninitialized register. This error is Itanium specific."
	else if SystemErrorCode == 0x4EE		
		return "The share is currently offline or does not exist."
	else if SystemErrorCode == 0x4EF		
		return "The Kerberos protocol encountered an error while validating the KDC certificate during smartcard logon. There is more information in the system event log."
	else if SystemErrorCode == 0x4F0		
		return "The Kerberos protocol encountered an error while attempting to utilize the smartcard subsystem."
	else if SystemErrorCode == 0x4F1		
		return "The system cannot contact a domain controller to service the authentication request. Please try again later."
	else if SystemErrorCode == 0x4F7		
		return "The machine is locked and cannot be shut down without the force option."
	else if SystemErrorCode == 0x4FA		
		return "The group policy framework should call the extension in the synchronous foreground policy refresh."
	else if SystemErrorCode == 0x4FB		
		return "This driver has been blocked from loading."
	else if SystemErrorCode == 0x4FD		
		return "Windows cannot open this program since it has been disabled."
	else if SystemErrorCode == 0x4FE		
		return "Windows cannot open this program because the license enforcement system has been tampered with or become corrupted."
	else if SystemErrorCode == 0x4FF		
		return "A transaction recover failed."
	else if SystemErrorCode == 0x500		
		return "The current thread has already been converted to a fiber."
	else if SystemErrorCode == 0x501		
		return "The current thread has already been converted from a fiber."
	else if SystemErrorCode == 0x503		
		return "Data present in one of the parameters is more than the function can operate on."
	else if SystemErrorCode == 0x504		
		return "An attempt to do an operation on a debug object failed because the object is in the process of being deleted."
	else if SystemErrorCode == 0x507		
		return "Insufficient information exists to identify the cause of failure."
	else if SystemErrorCode == 0x508		
		return "The parameter passed to a C runtime function is incorrect."
	else if SystemErrorCode == 0x509		
		return "The operation occurred beyond the valid data length of the file."
	else if SystemErrorCode == 0x50B		
		return "The process hosting the driver for this device has been terminated."
	else if SystemErrorCode == 0x50E		
		return "The service notification client is lagging too far behind the current state of services in the machine."
	else if SystemErrorCode == 0x512		
		return "A thread involved in this operation appears to be unresponsive."
	else if SystemErrorCode == 0x513		
		return "Indicates a particular Security ID may not be assigned as the label of an object."
	else if SystemErrorCode == 0x514		
		return "Not all privileges or groups referenced are assigned to the caller."
	else if SystemErrorCode == 0x515		
		return "Some mapping between account names and security IDs was not done."
	else if SystemErrorCode == 0x516		
		return "No system quota limits are specifically set for this account."
	else if SystemErrorCode == 0x519		
		return "The revision level is unknown."
	else if SystemErrorCode == 0x51A		
		return "Indicates two revision levels are incompatible."
	else if SystemErrorCode == 0x51B		
		return "This security ID may not be assigned as the owner of this object."
	else if SystemErrorCode == 0x51C		
		return "This security ID may not be assigned as the primary group of an object."
	else if SystemErrorCode == 0x51D		
		return "An attempt has been made to operate on an impersonation token by a thread that is not currently impersonating a client."
	else if SystemErrorCode == 0x51E		
		return "The group may not be disabled."
	else if SystemErrorCode == 0x51F		
		return "There are currently no logon servers available to service the logon request."
	else if SystemErrorCode == 0x520		
		return "A specified logon session does not exist. It may already have been terminated."
	else if SystemErrorCode == 0x521		
		return "A specified privilege does not exist."
	else if SystemErrorCode == 0x522		
		return "A required privilege is not held by the client."
	else if SystemErrorCode == 0x523		
		return "The name provided is not a properly formed account name."
	else if SystemErrorCode == 0x524		
		return "The specified account already exists."
	else if SystemErrorCode == 0x525		
		return "The specified account does not exist."
	else if SystemErrorCode == 0x526		
		return "The specified group already exists."
	else if SystemErrorCode == 0x527		
		return "The specified group does not exist."
	else if SystemErrorCode == 0x529		
		return "The specified user account is not a member of the specified group account."
	else if SystemErrorCode == 0x52B		
		return "Unable to update the password. The value provided as the current password is incorrect."
	else if SystemErrorCode == 0x52C		
		return "Unable to update the password. The value provided for the new password contains values that are not allowed in passwords."
	else if SystemErrorCode == 0x52E		
		return "The user name or password is incorrect."
	else if SystemErrorCode == 0x530		
		return "Your account has time restrictions that keep you from signing in right now."
	else if SystemErrorCode == 0x532		
		return "The password for this account has expired."
	else if SystemErrorCode == 0x534		
		return "No mapping between account names and security IDs was done."
	else if SystemErrorCode == 0x537		
		return "The subauthority part of a security ID is invalid for this particular use."
	else if SystemErrorCode == 0x539		
		return "The security ID structure is invalid."
	else if SystemErrorCode == 0x53A		
		return "The security descriptor structure is invalid."
	else if SystemErrorCode == 0x53D		
		return "The server is currently disabled."
	else if SystemErrorCode == 0x53E		
		return "The server is currently enabled."
	else if SystemErrorCode == 0x53F		
		return "The value provided was an invalid value for an identifier authority."
	else if SystemErrorCode == 0x540		
		return "No more memory is available for security information updates."
	else if SystemErrorCode == 0x543		
		return "Cannot open an anonymous level security token."
	else if SystemErrorCode == 0x544		
		return "The validation information class requested was invalid."
	else if SystemErrorCode == 0x545		
		return "The type of the token is inappropriate for its attempted use."
	else if SystemErrorCode == 0x546		
		return "Unable to perform a security operation on an object that has no associated security."
	else if SystemErrorCode == 0x549		
		return "The domain was in the wrong state to perform the security operation."
	else if SystemErrorCode == 0x54A		
		return "This operation is only allowed for the Primary Domain Controller of the domain."
	else if SystemErrorCode == 0x54B		
		return "The specified domain either does not exist or could not be contacted."
	else if SystemErrorCode == 0x54C		
		return "The specified domain already exists."
	else if SystemErrorCode == 0x54D		
		return "An attempt was made to exceed the limit on the number of domains per server."
	else if SystemErrorCode == 0x54E		
		return "Unable to complete the requested operation because of either a catastrophic media failure or a data structure corruption on the disk."
	else if SystemErrorCode == 0x54F		
		return "An internal error occurred."
	else if SystemErrorCode == 0x550		
		return "Generic access types were contained in an access mask which should already be mapped to nongeneric types."
	else if SystemErrorCode == 0x552		
		return "The requested action is restricted for use by logon processes only. The calling process has not registered as a logon process."
	else if SystemErrorCode == 0x553		
		return "Cannot start a new logon session with an ID that is already in use."
	else if SystemErrorCode == 0x554		
		return "A specified authentication package is unknown."
	else if SystemErrorCode == 0x555		
		return "The logon session is not in a state that is consistent with the requested operation."
	else if SystemErrorCode == 0x556		
		return "The logon session ID is already in use."
	else if SystemErrorCode == 0x557		
		return "A logon request contained an invalid logon type value."
	else if SystemErrorCode == 0x558		
		return "Unable to impersonate using a named pipe until data has been read from that pipe."
	else if SystemErrorCode == 0x559		
		return "The transaction state of a registry subtree is incompatible with the requested operation."
	else if SystemErrorCode == 0x55A		
		return "An internal security database corruption has been encountered."
	else if SystemErrorCode == 0x55F		
		return "The token is already in use as a primary token."
	else if SystemErrorCode == 0x560		
		return "The specified local group does not exist."
	else if SystemErrorCode == 0x561		
		return "The specified account name is not a member of the group."
	else if SystemErrorCode == 0x562		
		return "The specified account name is already a member of the group."
	else if SystemErrorCode == 0x563		
		return "The specified local group already exists."
	else if SystemErrorCode == 0x565		
		return "The maximum number of secrets that may be stored in a single system has been exceeded."
	else if SystemErrorCode == 0x566		
		return "The length of a secret exceeds the maximum length allowed."
	else if SystemErrorCode == 0x567		
		return "The local security authority database contains an internal inconsistency."
	else if SystemErrorCode == 0x56B		
		return "A member could not be added to or removed from the local group because the member does not exist."
	else if SystemErrorCode == 0x56C		
		return "A new member could not be added to a local group because the member has the wrong account type."
	else if SystemErrorCode == 0x56D		
		return "Too many security IDs have been specified."
	else if SystemErrorCode == 0x56F		
		return "Indicates an ACL contains no inheritable components."
	else if SystemErrorCode == 0x570		
		return "The file or directory is corrupted and unreadable."
	else if SystemErrorCode == 0x571		
		return "The disk structure is corrupted and unreadable."
	else if SystemErrorCode == 0x572		
		return "There is no user session key for the specified logon session."
	else if SystemErrorCode == 0x573		
		return "The service being accessed is licensed for a particular number of connections. No more connections can be made to the service at this time because there are already as many connections as the service can accept."
	else if SystemErrorCode == 0x574		
		return "The target account name is incorrect."
	else if SystemErrorCode == 0x577		
		return "This operation cannot be performed on the current domain."
	else if SystemErrorCode == 0x578		
		return "Invalid window handle."
	else if SystemErrorCode == 0x579		
		return "Invalid menu handle."
	else if SystemErrorCode == 0x57A		
		return "Invalid cursor handle."
	else if SystemErrorCode == 0x57B		
		return "Invalid accelerator table handle."
	else if SystemErrorCode == 0x57C		
		return "Invalid hook handle."
	else if SystemErrorCode == 0x57F		
		return "Cannot find window class."
	else if SystemErrorCode == 0x581		
		return "Hot key is already registered."
	else if SystemErrorCode == 0x582		
		return "Class already exists."
	else if SystemErrorCode == 0x583		
		return "Class does not exist."
	else if SystemErrorCode == 0x584		
		return "Class still has open windows."
	else if SystemErrorCode == 0x585		
		return "Invalid index."
	else if SystemErrorCode == 0x586		
		return "Invalid icon handle."
	else if SystemErrorCode == 0x587		
		return "Using private DIALOG window words."
	else if SystemErrorCode == 0x588		
		return "The list box identifier was not found."
	else if SystemErrorCode == 0x589		
		return "No wildcards were found."
	else if SystemErrorCode == 0x58A		
		return "Thread does not have a clipboard open."
	else if SystemErrorCode == 0x58B		
		return "Hot key is not registered."
	else if SystemErrorCode == 0x58C		
		return "The window is not a valid dialog window."
	else if SystemErrorCode == 0x58D		
		return "Control ID not found."
	else if SystemErrorCode == 0x58E		
		return "Invalid message for a combo box because it does not have an edit control."
	else if SystemErrorCode == 0x58F		
		return "The window is not a combo box."
	else if SystemErrorCode == 0x590		
		return "Height must be less than 256."
	else if SystemErrorCode == 0x592		
		return "Invalid hook procedure type."
	else if SystemErrorCode == 0x593		
		return "Invalid hook procedure."
	else if SystemErrorCode == 0x594		
		return "Cannot set nonlocal hook without a module handle."
	else if SystemErrorCode == 0x595		
		return "This hook procedure can only be set globally."
	else if SystemErrorCode == 0x596		
		return "The journal hook procedure is already installed."
	else if SystemErrorCode == 0x597		
		return "The hook procedure is not installed."
	else if SystemErrorCode == 0x59A		
		return "This list box does not support tab stops."
	else if SystemErrorCode == 0x59B		
		return "Cannot destroy object created by another thread."
	else if SystemErrorCode == 0x59C		
		return "Child windows cannot have menus."
	else if SystemErrorCode == 0x59D		
		return "The window does not have a system menu."
	else if SystemErrorCode == 0x59E		
		return "Invalid message box style."
	else if SystemErrorCode == 0x5A0		
		return "Screen already locked."
	else if SystemErrorCode == 0x5A2		
		return "The window is not a child window."
	else if SystemErrorCode == 0x5A4		
		return "Invalid thread identifier."
	else if SystemErrorCode == 0x5A6		
		return "Popup menu already active."
	else if SystemErrorCode == 0x5A7		
		return "The window does not have scroll bars."
	else if SystemErrorCode == 0x5A8		
		return "Scroll bar range cannot be greater than MAXLONG."
	else if SystemErrorCode == 0x5A9		
		return "Cannot show or remove the window in the way specified."
	else if SystemErrorCode == 0x5AA		
		return "Insufficient system resources exist to complete the requested service."
	else if SystemErrorCode == 0x5AB		
		return "Insufficient system resources exist to complete the requested service."
	else if SystemErrorCode == 0x5AC		
		return "Insufficient system resources exist to complete the requested service."
	else if SystemErrorCode == 0x5AD		
		return "Insufficient quota to complete the requested service."
	else if SystemErrorCode == 0x5AE		
		return "Insufficient quota to complete the requested service."
	else if SystemErrorCode == 0x5AF		
		return "The paging file is too small for this operation to complete."
	else if SystemErrorCode == 0x5B0		
		return "A menu item was not found."
	else if SystemErrorCode == 0x5B1		
		return "Invalid keyboard layout handle."
	else if SystemErrorCode == 0x5B2		
		return "Hook type not allowed."
	else if SystemErrorCode == 0x5B3		
		return "This operation requires an interactive window station."
	else if SystemErrorCode == 0x5B4		
		return "This operation returned because the timeout period expired."
	else if SystemErrorCode == 0x5B5		
		return "Invalid monitor handle."
	else if SystemErrorCode == 0x5B6		
		return "Incorrect size argument."
	else if SystemErrorCode == 0x5B7		
		return "The symbolic link cannot be followed because its type is disabled."
	else if SystemErrorCode == 0x5B8		
		return "This application does not support the current operation on symbolic links."
	else if SystemErrorCode == 0x5B9		
		return "Windows was unable to parse the requested XML data."
	else if SystemErrorCode == 0x5BA		
		return "An error was encountered while processing an XML digital signature."
	else if SystemErrorCode == 0x5BB		
		return "This application must be restarted."
	else if SystemErrorCode == 0x5BC		
		return "The caller made the connection request in the wrong routing compartment."
	else if SystemErrorCode == 0x5BD		
		return "There was an AuthIP failure when attempting to connect to the remote host."
	else if SystemErrorCode == 0x5BE		
		return "Insufficient NVRAM resources exist to complete the requested service. A reboot might be required."
	else if SystemErrorCode == 0x5BF		
		return "Unable to finish the requested operation because the specified process is not a GUI process."
	else if SystemErrorCode == 0x5DC		
		return "The event log file is corrupted."
	else if SystemErrorCode == 0x5DE		
		return "The event log file is full."
	else if SystemErrorCode == 0x5DF		
		return "The event log file has changed between read operations."
	else if SystemErrorCode == 0x60E		
		return "The specified task name is invalid."
	else if SystemErrorCode == 0x60F		
		return "The specified task index is invalid."
	else if SystemErrorCode == 0x610		
		return "The specified thread is already joining a task."
	else if SystemErrorCode == 0x641		
		return "The Windows Installer Service could not be accessed. This can occur if the Windows Installer is not correctly installed. Contact your support personnel for assistance."
	else if SystemErrorCode == 0x642		
		return "User cancelled installation."
	else if SystemErrorCode == 0x643		
		return "Fatal error during installation."
	else if SystemErrorCode == 0x645		
		return "This action is only valid for products that are currently installed."
	else if SystemErrorCode == 0x646		
		return "Feature ID not registered."
	else if SystemErrorCode == 0x647		
		return "Component ID not registered."
	else if SystemErrorCode == 0x648		
		return "Unknown property."
	else if SystemErrorCode == 0x649		
		return "Handle is in an invalid state."
	else if SystemErrorCode == 0x64A		
		return "The configuration data for this product is corrupt. Contact your support personnel."
	else if SystemErrorCode == 0x64B		
		return "Component qualifier not present."
	else if SystemErrorCode == 0x64C		
		return "The installation source for this product is not available. Verify that the source exists and that you can access it."
	else if SystemErrorCode == 0x64D		
		return "This installation package cannot be installed by the Windows Installer service. You must install a Windows service pack that contains a newer version of the Windows Installer service."
	else if SystemErrorCode == 0x64E		
		return "Product is uninstalled."
	else if SystemErrorCode == 0x64F		
		return "SQL query syntax invalid or unsupported."
	else if SystemErrorCode == 0x650		
		return "Record field does not exist."
	else if SystemErrorCode == 0x651		
		return "The device has been removed."
	else if SystemErrorCode == 0x652		
		return "Another installation is already in progress. Complete that installation before proceeding with this install."
	else if SystemErrorCode == 0x654		
		return "This installation package could not be opened. Contact the application vendor to verify that this is a valid Windows Installer package."
	else if SystemErrorCode == 0x655		
		return "There was an error starting the Windows Installer service user interface. Contact your support personnel."
	else if SystemErrorCode == 0x656		
		return "Error opening installation log file. Verify that the specified log file location exists and that you can write to it."
	else if SystemErrorCode == 0x657		
		return "The language of this installation package is not supported by your system."
	else if SystemErrorCode == 0x658		
		return "Error applying transforms. Verify that the specified transform paths are valid."
	else if SystemErrorCode == 0x659		
		return "This installation is forbidden by system policy. Contact your system administrator."
	else if SystemErrorCode == 0x65A		
		return "Function could not be executed."
	else if SystemErrorCode == 0x65B		
		return "Function failed during execution."
	else if SystemErrorCode == 0x65C		
		return "Invalid or unknown table specified."
	else if SystemErrorCode == 0x65D		
		return "Data supplied is of wrong type."
	else if SystemErrorCode == 0x65E		
		return "Data of this type is not supported."
	else if SystemErrorCode == 0x65F		
		return "The Windows Installer service failed to start. Contact your support personnel."
	else if SystemErrorCode == 0x660		
		return "The Temp folder is on a drive that is full or is inaccessible. Free up space on the drive or verify that you have write permission on the Temp folder."
	else if SystemErrorCode == 0x661		
		return "This installation package is not supported by this processor type. Contact your product vendor."
	else if SystemErrorCode == 0x662		
		return "Component not used on this computer."
	else if SystemErrorCode == 0x664		
		return "This update package could not be opened. Contact the application vendor to verify that this is a valid Windows Installer update package."
	else if SystemErrorCode == 0x665		
		return "This update package cannot be processed by the Windows Installer service. You must install a Windows service pack that contains a newer version of the Windows Installer service."
	else if SystemErrorCode == 0x667		
		return "Invalid command line argument. Consult the Windows Installer SDK for detailed command line help."
	else if SystemErrorCode == 0x669		
		return "The requested operation completed successfully. The system will be restarted so the changes can take effect."
	else if SystemErrorCode == 0x66B		
		return "The update package is not permitted by software restriction policy."
	else if SystemErrorCode == 0x66C		
		return "One or more customizations are not permitted by software restriction policy."
	else if SystemErrorCode == 0x66D		
		return "The Windows Installer does not permit installation from a Remote Desktop Connection."
	else if SystemErrorCode == 0x66E		
		return "Uninstallation of the update package is not supported."
	else if SystemErrorCode == 0x66F		
		return "The update is not applied to this product."
	else if SystemErrorCode == 0x670		
		return "No valid sequence could be found for the set of updates."
	else if SystemErrorCode == 0x671		
		return "Update removal was disallowed by policy."
	else if SystemErrorCode == 0x672		
		return "The XML update data is invalid."
	else if SystemErrorCode == 0x673		
		return "Windows Installer does not permit updating of managed advertised products. At least one feature of the product must be installed before applying the update."
	else if SystemErrorCode == 0x674		
		return "The Windows Installer service is not accessible in Safe Mode. Please try again when your computer is not in Safe Mode or you can use System Restore to return your machine to a previous good state."
	else if SystemErrorCode == 0x675		
		return "A fail fast exception occurred. Exception handlers will not be invoked and the process will be terminated immediately."
	else if SystemErrorCode == 0x676		
		return "The app that you are trying to run is not supported on this version of Windows."
	else if SystemErrorCode == 0x6A4		
		return "The string binding is invalid."
	else if SystemErrorCode == 0x6A5		
		return "The binding handle is not the correct type."
	else if SystemErrorCode == 0x6A6		
		return "The binding handle is invalid."
	else if SystemErrorCode == 0x6A7		
		return "The RPC protocol sequence is not supported."
	else if SystemErrorCode == 0x6A8		
		return "The RPC protocol sequence is invalid."
	else if SystemErrorCode == 0x6AA		
		return "The endpoint format is invalid."
	else if SystemErrorCode == 0x6AB		
		return "The network address is invalid."
	else if SystemErrorCode == 0x6AC		
		return "No endpoint was found."
	else if SystemErrorCode == 0x6AD		
		return "The timeout value is invalid."
	else if SystemErrorCode == 0x6B1		
		return "The RPC server is already listening."
	else if SystemErrorCode == 0x6B2		
		return "No protocol sequences have been registered."
	else if SystemErrorCode == 0x6B3		
		return "The RPC server is not listening."
	else if SystemErrorCode == 0x6B4		
		return "The manager type is unknown."
	else if SystemErrorCode == 0x6B5		
		return "The interface is unknown."
	else if SystemErrorCode == 0x6B6		
		return "There are no bindings."
	else if SystemErrorCode == 0x6B7		
		return "There are no protocol sequences."
	else if SystemErrorCode == 0x6B8		
		return "The endpoint cannot be created."
	else if SystemErrorCode == 0x6B9		
		return "Not enough resources are available to complete this operation."
	else if SystemErrorCode == 0x6BA		
		return "The RPC server is unavailable."
	else if SystemErrorCode == 0x6BB		
		return "The RPC server is too busy to complete this operation."
	else if SystemErrorCode == 0x6BC		
		return "The network options are invalid."
	else if SystemErrorCode == 0x6BD		
		return "There are no remote procedure calls active on this thread."
	else if SystemErrorCode == 0x6BE		
		return "The remote procedure call failed."
	else if SystemErrorCode == 0x6BF		
		return "The remote procedure call failed and did not execute."
	else if SystemErrorCode == 0x6C1		
		return "Access to the HTTP proxy is denied."
	else if SystemErrorCode == 0x6C2		
		return "The transfer syntax is not supported by the RPC server."
	else if SystemErrorCode == 0x6C5		
		return "The tag is invalid."
	else if SystemErrorCode == 0x6C6		
		return "The array bounds are invalid."
	else if SystemErrorCode == 0x6C7		
		return "The binding does not contain an entry name."
	else if SystemErrorCode == 0x6C8		
		return "The name syntax is invalid."
	else if SystemErrorCode == 0x6C9		
		return "The name syntax is not supported."
	else if SystemErrorCode == 0x6CC		
		return "The endpoint is a duplicate."
	else if SystemErrorCode == 0x6CD		
		return "The authentication type is unknown."
	else if SystemErrorCode == 0x6CE		
		return "The maximum number of calls is too small."
	else if SystemErrorCode == 0x6CF		
		return "The string is too long."
	else if SystemErrorCode == 0x6D0		
		return "The RPC protocol sequence was not found."
	else if SystemErrorCode == 0x6D1		
		return "The procedure number is out of range."
	else if SystemErrorCode == 0x6D2		
		return "The binding does not contain any authentication information."
	else if SystemErrorCode == 0x6D3		
		return "The authentication service is unknown."
	else if SystemErrorCode == 0x6D4		
		return "The authentication level is unknown."
	else if SystemErrorCode == 0x6D5		
		return "The security context is invalid."
	else if SystemErrorCode == 0x6D6		
		return "The authorization service is unknown."
	else if SystemErrorCode == 0x6D7		
		return "The entry is invalid."
	else if SystemErrorCode == 0x6D8		
		return "The server endpoint cannot perform the operation."
	else if SystemErrorCode == 0x6D9		
		return "There are no more endpoints available from the endpoint mapper."
	else if SystemErrorCode == 0x6DA		
		return "No interfaces have been exported."
	else if SystemErrorCode == 0x6DB		
		return "The entry name is incomplete."
	else if SystemErrorCode == 0x6DC		
		return "The version option is invalid."
	else if SystemErrorCode == 0x6DD		
		return "There are no more members."
	else if SystemErrorCode == 0x6DE		
		return "There is nothing to unexport."
	else if SystemErrorCode == 0x6DF		
		return "The interface was not found."
	else if SystemErrorCode == 0x6E0		
		return "The entry already exists."
	else if SystemErrorCode == 0x6E1		
		return "The entry is not found."
	else if SystemErrorCode == 0x6E2		
		return "The name service is unavailable."
	else if SystemErrorCode == 0x6E3		
		return "The network address family is invalid."
	else if SystemErrorCode == 0x6E4		
		return "The requested operation is not supported."
	else if SystemErrorCode == 0x6E5		
		return "No security context is available to allow impersonation."
	else if SystemErrorCode == 0x6E7		
		return "The RPC server attempted an integer division by zero."
	else if SystemErrorCode == 0x6E8		
		return "An addressing error occurred in the RPC server."
	else if SystemErrorCode == 0x6EC		
		return "The list of RPC servers available for the binding of auto handles has been exhausted."
	else if SystemErrorCode == 0x6ED		
		return "Unable to open the character translation table file."
	else if SystemErrorCode == 0x6EE		
		return "The file containing the character translation table has fewer than 512 bytes."
	else if SystemErrorCode == 0x6EF		
		return "A null context handle was passed from the client to the host during a remote procedure call."
	else if SystemErrorCode == 0x6F1		
		return "The context handle changed during a remote procedure call."
	else if SystemErrorCode == 0x6F2		
		return "The binding handles passed to a remote procedure call do not match."
	else if SystemErrorCode == 0x6F3		
		return "The stub is unable to get the remote procedure call handle."
	else if SystemErrorCode == 0x6F4		
		return "A null reference pointer was passed to the stub."
	else if SystemErrorCode == 0x6F5		
		return "The enumeration value is out of range."
	else if SystemErrorCode == 0x6F6		
		return "The byte count is too small."
	else if SystemErrorCode == 0x6F7		
		return "The stub received bad data."
	else if SystemErrorCode == 0x6F8		
		return "The supplied user buffer is not valid for the requested operation."
	else if SystemErrorCode == 0x6F9		
		return "The disk media is not recognized. It may not be formatted."
	else if SystemErrorCode == 0x6FA		
		return "The workstation does not have a trust secret."
	else if SystemErrorCode == 0x6FB		
		return "The security database on the server does not have a computer account for this workstation trust relationship."
	else if SystemErrorCode == 0x6FC		
		return "The trust relationship between the primary domain and the trusted domain failed."
	else if SystemErrorCode == 0x6FD		
		return "The trust relationship between this workstation and the primary domain failed."
	else if SystemErrorCode == 0x6FE		
		return "The network logon failed."
	else if SystemErrorCode == 0x6FF		
		return "A remote procedure call is already in progress for this thread."
	else if SystemErrorCode == 0x702		
		return "The redirector is in use and cannot be unloaded."
	else if SystemErrorCode == 0x703		
		return "The specified printer driver is already installed."
	else if SystemErrorCode == 0x704		
		return "The specified port is unknown."
	else if SystemErrorCode == 0x705		
		return "The printer driver is unknown."
	else if SystemErrorCode == 0x706		
		return "The print processor is unknown."
	else if SystemErrorCode == 0x707		
		return "The specified separator file is invalid."
	else if SystemErrorCode == 0x708		
		return "The specified priority is invalid."
	else if SystemErrorCode == 0x709		
		return "The printer name is invalid."
	else if SystemErrorCode == 0x70A		
		return "The printer already exists."
	else if SystemErrorCode == 0x70B		
		return "The printer command is invalid."
	else if SystemErrorCode == 0x70C		
		return "The specified datatype is invalid."
	else if SystemErrorCode == 0x70D		
		return "The environment specified is invalid."
	else if SystemErrorCode == 0x70E		
		return "There are no more bindings."
	else if SystemErrorCode == 0x70F		
		return "The account used is an interdomain trust account. Use your global user account or local user account to access this server."
	else if SystemErrorCode == 0x710		
		return "The account used is a computer account. Use your global user account or local user account to access this server."
	else if SystemErrorCode == 0x711		
		return "The account used is a server trust account. Use your global user account or local user account to access this server."
	else if SystemErrorCode == 0x713		
		return "The server is in use and cannot be unloaded."
	else if SystemErrorCode == 0x714		
		return "The specified image file did not contain a resource section."
	else if SystemErrorCode == 0x715		
		return "The specified resource type cannot be found in the image file."
	else if SystemErrorCode == 0x716		
		return "The specified resource name cannot be found in the image file."
	else if SystemErrorCode == 0x717		
		return "The specified resource language ID cannot be found in the image file."
	else if SystemErrorCode == 0x718		
		return "Not enough quota is available to process this command."
	else if SystemErrorCode == 0x719		
		return "No interfaces have been registered."
	else if SystemErrorCode == 0x71A		
		return "The remote procedure call was cancelled."
	else if SystemErrorCode == 0x71B		
		return "The binding handle does not contain all required information."
	else if SystemErrorCode == 0x71C		
		return "A communications failure occurred during a remote procedure call."
	else if SystemErrorCode == 0x71D		
		return "The requested authentication level is not supported."
	else if SystemErrorCode == 0x71E		
		return "No principal name registered."
	else if SystemErrorCode == 0x71F		
		return "The error specified is not a valid Windows RPC error code."
	else if SystemErrorCode == 0x720		
		return "A UUID that is valid only on this computer has been allocated."
	else if SystemErrorCode == 0x721		
		return "A security package specific error occurred."
	else if SystemErrorCode == 0x722		
		return "Thread is not canceled."
	else if SystemErrorCode == 0x724		
		return "Incompatible version of the serializing package."
	else if SystemErrorCode == 0x725		
		return "Incompatible version of the RPC stub."
	else if SystemErrorCode == 0x726		
		return "The RPC pipe object is invalid or corrupted."
	else if SystemErrorCode == 0x727		
		return "An invalid operation was attempted on an RPC pipe object."
	else if SystemErrorCode == 0x728		
		return "Unsupported RPC pipe version."
	else if SystemErrorCode == 0x729		
		return "HTTP proxy server rejected the connection because the cookie authentication failed."
	else if SystemErrorCode == 0x76A		
		return "The group member was not found."
	else if SystemErrorCode == 0x76B		
		return "The endpoint mapper database entry could not be created."
	else if SystemErrorCode == 0x76D		
		return "The specified time is invalid."
	else if SystemErrorCode == 0x76E		
		return "The specified form name is invalid."
	else if SystemErrorCode == 0x76F		
		return "The specified form size is invalid."
	else if SystemErrorCode == 0x770		
		return "The specified printer handle is already being waited on."
	else if SystemErrorCode == 0x771		
		return "The specified printer has been deleted."
	else if SystemErrorCode == 0x772		
		return "The state of the printer is invalid."
	else if SystemErrorCode == 0x774		
		return "Could not find the domain controller for this domain."
	else if SystemErrorCode == 0x775		
		return "The referenced account is currently locked out and may not be logged on to."
	else if SystemErrorCode == 0x776		
		return "The object exporter specified was not found."
	else if SystemErrorCode == 0x777		
		return "The object specified was not found."
	else if SystemErrorCode == 0x778		
		return "The object resolver set specified was not found."
	else if SystemErrorCode == 0x779		
		return "Some data remains to be sent in the request buffer."
	else if SystemErrorCode == 0x77A		
		return "Invalid asynchronous remote procedure call handle."
	else if SystemErrorCode == 0x77B		
		return "Invalid asynchronous RPC call handle for this operation."
	else if SystemErrorCode == 0x77C		
		return "The RPC pipe object has already been closed."
	else if SystemErrorCode == 0x77D		
		return "The RPC call completed before all pipes were processed."
	else if SystemErrorCode == 0x77E		
		return "No more data is available from the RPC pipe."
	else if SystemErrorCode == 0x77F		
		return "No site name is available for this machine."
	else if SystemErrorCode == 0x780		
		return "The file cannot be accessed by the system."
	else if SystemErrorCode == 0x781		
		return "The name of the file cannot be resolved by the system."
	else if SystemErrorCode == 0x782		
		return "The entry is not of the expected type."
	else if SystemErrorCode == 0x783		
		return "Not all object UUIDs could be exported to the specified entry."
	else if SystemErrorCode == 0x784		
		return "Interface could not be exported to the specified entry."
	else if SystemErrorCode == 0x785		
		return "The specified profile entry could not be added."
	else if SystemErrorCode == 0x786		
		return "The specified profile element could not be added."
	else if SystemErrorCode == 0x787		
		return "The specified profile element could not be removed."
	else if SystemErrorCode == 0x788		
		return "The group element could not be added."
	else if SystemErrorCode == 0x789		
		return "The group element could not be removed."
	else if SystemErrorCode == 0x78A		
		return "The printer driver is not compatible with a policy enabled on your computer that blocks NT 4.0 drivers."
	else if SystemErrorCode == 0x78B		
		return "The context has expired and can no longer be used."
	else if SystemErrorCode == 0x78D		
		return "The total delegated trust creation quota has been exceeded."
	else if SystemErrorCode == 0x78F		
		return "The computer you are signing into is protected by an authentication firewall. The specified account is not allowed to authenticate to the computer."
	else if SystemErrorCode == 0x790		
		return "Remote connections to the Print Spooler are blocked by a policy set on your machine."
	else if SystemErrorCode == 0x791		
		return "Authentication failed because NTLM authentication has been disabled."
	else if SystemErrorCode == 0x7D0		
		return "The pixel format is invalid."
	else if SystemErrorCode == 0x7D1		
		return "The specified driver is invalid."
	else if SystemErrorCode == 0x7D2		
		return "The window style or class attribute is invalid for this operation."
	else if SystemErrorCode == 0x7D3		
		return "The requested metafile operation is not supported."
	else if SystemErrorCode == 0x7D4		
		return "The requested transformation operation is not supported."
	else if SystemErrorCode == 0x7D5		
		return "The requested clipping operation is not supported."
	else if SystemErrorCode == 0x7DA		
		return "The specified color management module is invalid."
	else if SystemErrorCode == 0x7DB		
		return "The specified color profile is invalid."
	else if SystemErrorCode == 0x7DC		
		return "The specified tag was not found."
	else if SystemErrorCode == 0x7DD		
		return "A required tag is not present."
	else if SystemErrorCode == 0x7DE		
		return "The specified tag is already present."
	else if SystemErrorCode == 0x7DF		
		return "The specified color profile is not associated with the specified device."
	else if SystemErrorCode == 0x7E0		
		return "The specified color profile was not found."
	else if SystemErrorCode == 0x7E1		
		return "The specified color space is invalid."
	else if SystemErrorCode == 0x7E2		
		return "Image Color Management is not enabled."
	else if SystemErrorCode == 0x7E3		
		return "There was an error while deleting the color transform."
	else if SystemErrorCode == 0x7E4		
		return "The specified color transform is invalid."
	else if SystemErrorCode == 0x7E6		
		return "The specified named color index is not present in the profile."
	else if SystemErrorCode == 0x7E7		
		return "The specified profile is intended for a device of a different type than the specified device."
	else if SystemErrorCode == 0x83D		
		return "The network connection was made successfully using default credentials."
	else if SystemErrorCode == 0x89A		
		return "The specified username is invalid."
	else if SystemErrorCode == 0x8CA		
		return "This network connection does not exist."
	else if SystemErrorCode == 0x961		
		return "This network connection has files open or requests pending."
	else if SystemErrorCode == 0x962		
		return "Active connections still exist."
	else if SystemErrorCode == 0x964		
		return "The device is in use by an active process and cannot be disconnected."
	else if SystemErrorCode == 0xBB8		
		return "The specified print monitor is unknown."
	else if SystemErrorCode == 0xBB9		
		return "The specified printer driver is currently in use."
	else if SystemErrorCode == 0xBBA		
		return "The spool file was not found."
	else if SystemErrorCode == 0xBBB		
		return "A StartDocPrinter call was not issued."
	else if SystemErrorCode == 0xBBC		
		return "An AddJob call was not issued."
	else if SystemErrorCode == 0xBBD		
		return "The specified print processor has already been installed."
	else if SystemErrorCode == 0xBBE		
		return "The specified print monitor has already been installed."
	else if SystemErrorCode == 0xBBF		
		return "The specified print monitor does not have the required functions."
	else if SystemErrorCode == 0xBC0		
		return "The specified print monitor is currently in use."
	else if SystemErrorCode == 0xBC1		
		return "The requested operation is not allowed when there are jobs queued to the printer."
	else if SystemErrorCode == 0xBC2		
		return "The requested operation is successful. Changes will not be effective until the system is rebooted."
	else if SystemErrorCode == 0xBC3		
		return "The requested operation is successful. Changes will not be effective until the service is restarted."
	else if SystemErrorCode == 0xBC4		
		return "No printers were found."
	else if SystemErrorCode == 0xBC5		
		return "The printer driver is known to be unreliable."
	else if SystemErrorCode == 0xBC6		
		return "The printer driver is known to harm the system."
	else if SystemErrorCode == 0xBC7		
		return "The specified printer driver package is currently in use."
	else if SystemErrorCode == 0xBC8		
		return "Unable to find a core driver package that is required by the printer driver package."
	else if SystemErrorCode == 0xBC9		
		return "The requested operation failed. A system reboot is required to roll back changes made."
	else if SystemErrorCode == 0xBCA		
		return "The requested operation failed. A system reboot has been initiated to roll back changes made."
	else if SystemErrorCode == 0xBCB		
		return "The specified printer driver was not found on the system and needs to be downloaded."
	else if SystemErrorCode == 0xBCC		
		return "The requested print job has failed to print. A print system update requires the job to be resubmitted."
	else if SystemErrorCode == 0xBCE		
		return "The specified printer cannot be shared."
	else if SystemErrorCode == 0xBEA		
		return "The operation was paused."
	else if SystemErrorCode == 0xF6E		
		return "Reissue the given operation as a cached IO operation."
	else if SystemErrorCode == 0xFA0		
		return "WINS encountered an error while processing the command."
	else if SystemErrorCode == 0xFA1		
		return "The local WINS cannot be deleted."
	else if SystemErrorCode == 0xFA2		
		return "The importation from the file failed."
	else if SystemErrorCode == 0xFA4		
		return "The backup failed. Check the directory to which you are backing the database."
	else if SystemErrorCode == 0xFA5		
		return "The name does not exist in the WINS database."
	else if SystemErrorCode == 0xFA6		
		return "Replication with a nonconfigured partner is not allowed."
	else if SystemErrorCode == 0xFD2		
		return "The version of the supplied content information is not supported."
	else if SystemErrorCode == 0xFD3		
		return "The supplied content information is malformed."
	else if SystemErrorCode == 0xFD4		
		return "The requested data cannot be found in local or peer caches."
	else if SystemErrorCode == 0xFD5		
		return "No more data is available or required."
	else if SystemErrorCode == 0xFD6		
		return "The supplied object has not been initialized."
	else if SystemErrorCode == 0xFD7		
		return "The supplied object has already been initialized."
	else if SystemErrorCode == 0xFD8		
		return "A shutdown operation is already in progress."
	else if SystemErrorCode == 0xFD9		
		return "The supplied object has already been invalidated."
	else if SystemErrorCode == 0xFDA		
		return "An element already exists and was not replaced."
	else if SystemErrorCode == 0xFDB		
		return "Can not cancel the requested operation as it has already been completed."
	else if SystemErrorCode == 0xFDC		
		return "Can not perform the reqested operation because it has already been carried out."
	else if SystemErrorCode == 0xFDD		
		return "An operation accessed data beyond the bounds of valid data."
	else if SystemErrorCode == 0xFDE		
		return "The requested version is not supported."
	else if SystemErrorCode == 0xFDF		
		return "A configuration value is invalid."
	else if SystemErrorCode == 0xFE0		
		return "The SKU is not licensed."
	else if SystemErrorCode == 0xFE1		
		return "PeerDist Service is still initializing and will be available shortly."
	else if SystemErrorCode == 0xFE2		
		return "Communication with one or more computers will be temporarily blocked due to recent errors."
	else if SystemErrorCode == 0x1004		
		return "The DHCP client has obtained an IP address that is already in use on the network. The local interface will be disabled until the DHCP client can obtain a new address."
	else if SystemErrorCode == 0x1068		
		return "The GUID passed was not recognized as valid by a WMI data provider."
	else if SystemErrorCode == 0x1069		
		return "The instance name passed was not recognized as valid by a WMI data provider."
	else if SystemErrorCode == 0x106A		
		return "The data item ID passed was not recognized as valid by a WMI data provider."
	else if SystemErrorCode == 0x106B		
		return "The WMI request could not be completed and should be retried."
	else if SystemErrorCode == 0x106C		
		return "The WMI data provider could not be located."
	else if SystemErrorCode == 0x106D		
		return "The WMI data provider references an instance set that has not been registered."
	else if SystemErrorCode == 0x106E		
		return "The WMI data block or event notification has already been enabled."
	else if SystemErrorCode == 0x106F		
		return "The WMI data block is no longer available."
	else if SystemErrorCode == 0x1070		
		return "The WMI data service is not available."
	else if SystemErrorCode == 0x1071		
		return "The WMI data provider failed to carry out the request."
	else if SystemErrorCode == 0x1072		
		return "The WMI MOF information is not valid."
	else if SystemErrorCode == 0x1073		
		return "The WMI registration information is not valid."
	else if SystemErrorCode == 0x1074		
		return "The WMI data block or event notification has already been disabled."
	else if SystemErrorCode == 0x1075		
		return "The WMI data item or data block is read only."
	else if SystemErrorCode == 0x1076		
		return "The WMI data item or data block could not be changed."
	else if SystemErrorCode == 0x109A		
		return "This operation is only valid in the context of an app container."
	else if SystemErrorCode == 0x109B		
		return "This application can only run in the context of an app container."
	else if SystemErrorCode == 0x109C		
		return "This functionality is not supported in the context of an app container."
	else if SystemErrorCode == 0x109D		
		return "The length of the SID supplied is not a valid length for app container SIDs."
	else if SystemErrorCode == 0x10CC		
		return "The media identifier does not represent a valid medium."
	else if SystemErrorCode == 0x10CD		
		return "The library identifier does not represent a valid library."
	else if SystemErrorCode == 0x10CE		
		return "The media pool identifier does not represent a valid media pool."
	else if SystemErrorCode == 0x10CF		
		return "The drive and medium are not compatible or exist in different libraries."
	else if SystemErrorCode == 0x10D0		
		return "The medium currently exists in an offline library and must be online to perform this operation."
	else if SystemErrorCode == 0x10D1		
		return "The operation cannot be performed on an offline library."
	else if SystemErrorCode == 0x10D4		
		return "No media is currently available in this media pool or library."
	else if SystemErrorCode == 0x10D5		
		return "A resource required for this operation is disabled."
	else if SystemErrorCode == 0x10D6		
		return "The media identifier does not represent a valid cleaner."
	else if SystemErrorCode == 0x10D7		
		return "The drive cannot be cleaned or does not support cleaning."
	else if SystemErrorCode == 0x10D8		
		return "The object identifier does not represent a valid object."
	else if SystemErrorCode == 0x10D9		
		return "Unable to read from or write to the database."
	else if SystemErrorCode == 0x10DA		
		return "The database is full."
	else if SystemErrorCode == 0x10DB		
		return "The medium is not compatible with the device or media pool."
	else if SystemErrorCode == 0x10DC		
		return "The resource required for this operation does not exist."
	else if SystemErrorCode == 0x10DD		
		return "The operation identifier is not valid."
	else if SystemErrorCode == 0x10DE		
		return "The media is not mounted or ready for use."
	else if SystemErrorCode == 0x10DF		
		return "The device is not ready for use."
	else if SystemErrorCode == 0x10E0		
		return "The operator or administrator has refused the request."
	else if SystemErrorCode == 0x10E1		
		return "The drive identifier does not represent a valid drive."
	else if SystemErrorCode == 0x10E2		
		return "Library is full. No slot is available for use."
	else if SystemErrorCode == 0x10E3		
		return "The transport cannot access the medium."
	else if SystemErrorCode == 0x10E4		
		return "Unable to load the medium into the drive."
	else if SystemErrorCode == 0x10E5		
		return "Unable to retrieve the drive status."
	else if SystemErrorCode == 0x10E6		
		return "Unable to retrieve the slot status."
	else if SystemErrorCode == 0x10E7		
		return "Unable to retrieve status about the transport."
	else if SystemErrorCode == 0x10E8		
		return "Cannot use the transport because it is already in use."
	else if SystemErrorCode == 0x10EA		
		return "Unable to eject the medium because it is in a drive."
	else if SystemErrorCode == 0x10EB		
		return "A cleaner slot is already reserved."
	else if SystemErrorCode == 0x10EC		
		return "A cleaner slot is not reserved."
	else if SystemErrorCode == 0x10ED		
		return "The cleaner cartridge has performed the maximum number of drive cleanings."
	else if SystemErrorCode == 0x10EF		
		return "The last remaining item in this group or resource cannot be deleted."
	else if SystemErrorCode == 0x10F0		
		return "The message provided exceeds the maximum size allowed for this parameter."
	else if SystemErrorCode == 0x10F1		
		return "The volume contains system or paging files."
	else if SystemErrorCode == 0x10F2		
		return "The media type cannot be removed from this library since at least one drive in the library reports it can support this media type."
	else if SystemErrorCode == 0x10F3		
		return "This offline media cannot be mounted on this system since no enabled drives are present which can be used."
	else if SystemErrorCode == 0x10F4		
		return "A cleaner cartridge is present in the tape library."
	else if SystemErrorCode == 0x10FE		
		return "This file is currently not available for use on this computer."
	else if SystemErrorCode == 0x10FF		
		return "The remote storage service is not operational at this time."
	else if SystemErrorCode == 0x1100		
		return "The remote storage service encountered a media error."
	else if SystemErrorCode == 0x1126		
		return "The file or directory is not a reparse point."
	else if SystemErrorCode == 0x1127		
		return "The reparse point attribute cannot be set because it conflicts with an existing attribute."
	else if SystemErrorCode == 0x1128		
		return "The data present in the reparse point buffer is invalid."
	else if SystemErrorCode == 0x1129		
		return "The tag present in the reparse point buffer is invalid."
	else if SystemErrorCode == 0x112A		
		return "There is a mismatch between the tag specified in the request and the tag present in the reparse point."
	else if SystemErrorCode == 0x1130		
		return "Fast Cache data not found."
	else if SystemErrorCode == 0x1131		
		return "Fast Cache data expired."
	else if SystemErrorCode == 0x1132		
		return "Fast Cache data corrupt."
	else if SystemErrorCode == 0x1133		
		return "Fast Cache data has exceeded its max size and cannot be updated."
	else if SystemErrorCode == 0x1134		
		return "Fast Cache has been ReArmed and requires a reboot until it can be updated."
	else if SystemErrorCode == 0x1144		
		return "Secure Boot detected that rollback of protected data has been attempted."
	else if SystemErrorCode == 0x1145		
		return "The value is protected by Secure Boot policy and cannot be modified or deleted."
	else if SystemErrorCode == 0x1146		
		return "The Secure Boot policy is invalid."
	else if SystemErrorCode == 0x1147		
		return "A new Secure Boot policy did not contain the current publisher on its update list."
	else if SystemErrorCode == 0x1149		
		return "Secure Boot is not enabled on this machine."
	else if SystemErrorCode == 0x114A		
		return "Secure Boot requires that certain files and drivers are not replaced by other files or drivers."
	else if SystemErrorCode == 0x1158		
		return "The copy offload read operation is not supported by a filter."
	else if SystemErrorCode == 0x1159		
		return "The copy offload write operation is not supported by a filter."
	else if SystemErrorCode == 0x115A		
		return "The copy offload read operation is not supported for the file."
	else if SystemErrorCode == 0x115B		
		return "The copy offload write operation is not supported for the file."
	else if SystemErrorCode == 0x1194		
		return "Single Instance Storage is not available on this volume."
	else if SystemErrorCode == 0x1389		
		return "The operation cannot be completed because other resources are dependent on this resource."
	else if SystemErrorCode == 0x138A		
		return "The cluster resource dependency cannot be found."
	else if SystemErrorCode == 0x138B		
		return "The cluster resource cannot be made dependent on the specified resource because it is already dependent."
	else if SystemErrorCode == 0x138C		
		return "The cluster resource is not online."
	else if SystemErrorCode == 0x138D		
		return "A cluster node is not available for this operation."
	else if SystemErrorCode == 0x138E		
		return "The cluster resource is not available."
	else if SystemErrorCode == 0x138F		
		return "The cluster resource could not be found."
	else if SystemErrorCode == 0x1390		
		return "The cluster is being shut down."
	else if SystemErrorCode == 0x1391		
		return "A cluster node cannot be evicted from the cluster unless the node is down or it is the last node."
	else if SystemErrorCode == 0x1392		
		return "The object already exists."
	else if SystemErrorCode == 0x1393		
		return "The object is already in the list."
	else if SystemErrorCode == 0x1394		
		return "The cluster group is not available for any new requests."
	else if SystemErrorCode == 0x1395		
		return "The cluster group could not be found."
	else if SystemErrorCode == 0x1396		
		return "The operation could not be completed because the cluster group is not online."
	else if SystemErrorCode == 0x1399		
		return "The cluster resource could not be created in the specified resource monitor."
	else if SystemErrorCode == 0x139A		
		return "The cluster resource could not be brought online by the resource monitor."
	else if SystemErrorCode == 0x139B		
		return "The operation could not be completed because the cluster resource is online."
	else if SystemErrorCode == 0x139C		
		return "The cluster resource could not be deleted or brought offline because it is the quorum resource."
	else if SystemErrorCode == 0x139D		
		return "The cluster could not make the specified resource a quorum resource because it is not capable of being a quorum resource."
	else if SystemErrorCode == 0x139E		
		return "The cluster software is shutting down."
	else if SystemErrorCode == 0x139F		
		return "The group or resource is not in the correct state to perform the requested operation."
	else if SystemErrorCode == 0x13A0		
		return "The properties were stored but not all changes will take effect until the next time the resource is brought online."
	else if SystemErrorCode == 0x13A1		
		return "The cluster could not make the specified resource a quorum resource because it does not belong to a shared storage class."
	else if SystemErrorCode == 0x13A2		
		return "The cluster resource could not be deleted since it is a core resource."
	else if SystemErrorCode == 0x13A3		
		return "The quorum resource failed to come online."
	else if SystemErrorCode == 0x13A4		
		return "The quorum log could not be created or mounted successfully."
	else if SystemErrorCode == 0x13A5		
		return "The cluster log is corrupt."
	else if SystemErrorCode == 0x13A6		
		return "The record could not be written to the cluster log since it exceeds the maximum size."
	else if SystemErrorCode == 0x13A7		
		return "The cluster log exceeds its maximum size."
	else if SystemErrorCode == 0x13A8		
		return "No checkpoint record was found in the cluster log."
	else if SystemErrorCode == 0x13A9		
		return "The minimum required disk space needed for logging is not available."
	else if SystemErrorCode == 0x13AA		
		return "The cluster node failed to take control of the quorum resource because the resource is owned by another active node."
	else if SystemErrorCode == 0x13AB		
		return "A cluster network is not available for this operation."
	else if SystemErrorCode == 0x13AC		
		return "A cluster node is not available for this operation."
	else if SystemErrorCode == 0x13AD		
		return "All cluster nodes must be running to perform this operation."
	else if SystemErrorCode == 0x13AE		
		return "A cluster resource failed."
	else if SystemErrorCode == 0x13AF		
		return "The cluster node is not valid."
	else if SystemErrorCode == 0x13B0		
		return "The cluster node already exists."
	else if SystemErrorCode == 0x13B1		
		return "A node is in the process of joining the cluster."
	else if SystemErrorCode == 0x13B2		
		return "The cluster node was not found."
	else if SystemErrorCode == 0x13B3		
		return "The cluster local node information was not found."
	else if SystemErrorCode == 0x13B4		
		return "The cluster network already exists."
	else if SystemErrorCode == 0x13B5		
		return "The cluster network was not found."
	else if SystemErrorCode == 0x13B6		
		return "The cluster network interface already exists."
	else if SystemErrorCode == 0x13B7		
		return "The cluster network interface was not found."
	else if SystemErrorCode == 0x13B8		
		return "The cluster request is not valid for this object."
	else if SystemErrorCode == 0x13B9		
		return "The cluster network provider is not valid."
	else if SystemErrorCode == 0x13BA		
		return "The cluster node is down."
	else if SystemErrorCode == 0x13BB		
		return "The cluster node is not reachable."
	else if SystemErrorCode == 0x13BC		
		return "The cluster node is not a member of the cluster."
	else if SystemErrorCode == 0x13BD		
		return "A cluster join operation is not in progress."
	else if SystemErrorCode == 0x13BE		
		return "The cluster network is not valid."
	else if SystemErrorCode == 0x13C0		
		return "The cluster node is up."
	else if SystemErrorCode == 0x13C1		
		return "The cluster IP address is already in use."
	else if SystemErrorCode == 0x13C2		
		return "The cluster node is not paused."
	else if SystemErrorCode == 0x13C3		
		return "No cluster security context is available."
	else if SystemErrorCode == 0x13C4		
		return "The cluster network is not configured for internal cluster communication."
	else if SystemErrorCode == 0x13C5		
		return "The cluster node is already up."
	else if SystemErrorCode == 0x13C6		
		return "The cluster node is already down."
	else if SystemErrorCode == 0x13C7		
		return "The cluster network is already online."
	else if SystemErrorCode == 0x13C8		
		return "The cluster network is already offline."
	else if SystemErrorCode == 0x13C9		
		return "The cluster node is already a member of the cluster."
	else if SystemErrorCode == 0x13CA		
		return "The cluster network is the only one configured for internal cluster communication between two or more active cluster nodes. The internal communication capability cannot be removed from the network."
	else if SystemErrorCode == 0x13CB		
		return "One or more cluster resources depend on the network to provide service to clients. The client access capability cannot be removed from the network."
	else if SystemErrorCode == 0x13CC		
		return "This operation cannot be performed on the cluster resource as it the quorum resource. You may not bring the quorum resource offline or modify its possible owners list."
	else if SystemErrorCode == 0x13CD		
		return "The cluster quorum resource is not allowed to have any dependencies."
	else if SystemErrorCode == 0x13CE		
		return "The cluster node is paused."
	else if SystemErrorCode == 0x13CF		
		return "The cluster resource cannot be brought online. The owner node cannot run this resource."
	else if SystemErrorCode == 0x13D0		
		return "The cluster node is not ready to perform the requested operation."
	else if SystemErrorCode == 0x13D1		
		return "The cluster node is shutting down."
	else if SystemErrorCode == 0x13D2		
		return "The cluster join operation was aborted."
	else if SystemErrorCode == 0x13D3		
		return "The cluster join operation failed due to incompatible software versions between the joining node and its sponsor."
	else if SystemErrorCode == 0x13D4		
		return "This resource cannot be created because the cluster has reached the limit on the number of resources it can monitor."
	else if SystemErrorCode == 0x13D5		
		return "The system configuration changed during the cluster join or form operation. The join or form operation was aborted."
	else if SystemErrorCode == 0x13D6		
		return "The specified resource type was not found."
	else if SystemErrorCode == 0x13D7		
		return "The specified node does not support a resource of this type. This may be due to version inconsistencies or due to the absence of the resource DLL on this node."
	else if SystemErrorCode == 0x13D9		
		return "No authentication package could be registered with the RPC server."
	else if SystemErrorCode == 0x13DB		
		return "The join operation failed because the cluster database sequence number has changed or is incompatible with the locker node. This may happen during a join operation if the cluster database was changing during the join."
	else if SystemErrorCode == 0x13DC		
		return "The resource monitor will not allow the fail operation to be performed while the resource is in its current state. This may happen if the resource is in a pending state."
	else if SystemErrorCode == 0x13DD		
		return "A non locker code got a request to reserve the lock for making global updates."
	else if SystemErrorCode == 0x13DE		
		return "The quorum disk could not be located by the cluster service."
	else if SystemErrorCode == 0x13DF		
		return "The backed up cluster database is possibly corrupt."
	else if SystemErrorCode == 0x13E0		
		return "A DFS root already exists in this cluster node."
	else if SystemErrorCode == 0x13E1		
		return "An attempt to modify a resource property failed because it conflicts with another existing property."
	else if SystemErrorCode == 0x1702		
		return "An operation was attempted that is incompatible with the current membership state of the node."
	else if SystemErrorCode == 0x1703		
		return "The quorum resource does not contain the quorum log."
	else if SystemErrorCode == 0x1704		
		return "The membership engine requested shutdown of the cluster service on this node."
	else if SystemErrorCode == 0x1705		
		return "The join operation failed because the cluster instance ID of the joining node does not match the cluster instance ID of the sponsor node."
	else if SystemErrorCode == 0x1706		
		return "A matching cluster network for the specified IP address could not be found."
	else if SystemErrorCode == 0x1707		
		return "The actual data type of the property did not match the expected data type of the property."
	else if SystemErrorCode == 0x170A		
		return "This computer cannot be made a member of a cluster."
	else if SystemErrorCode == 0x170B		
		return "This computer cannot be made a member of a cluster because it does not have the correct version of Windows installed."
	else if SystemErrorCode == 0x170C		
		return "A cluster cannot be created with the specified cluster name because that cluster name is already in use. Specify a different name for the cluster."
	else if SystemErrorCode == 0x170D		
		return "The cluster configuration action has already been committed."
	else if SystemErrorCode == 0x170E		
		return "The cluster configuration action could not be rolled back."
	else if SystemErrorCode == 0x170F		
		return "The drive letter assigned to a system disk on one node conflicted with the drive letter assigned to a disk on another node."
	else if SystemErrorCode == 0x1710		
		return "One or more nodes in the cluster are running a version of Windows that does not support this operation."
	else if SystemErrorCode == 0x1712		
		return "No network adapters are available."
	else if SystemErrorCode == 0x1713		
		return "The cluster node has been poisoned."
	else if SystemErrorCode == 0x1714		
		return "The group is unable to accept the request since it is moving to another node."
	else if SystemErrorCode == 0x1715		
		return "The resource type cannot accept the request since is too busy performing another operation."
	else if SystemErrorCode == 0x1716		
		return "The call to the cluster resource DLL timed out."
	else if SystemErrorCode == 0x1718		
		return "An internal cluster error occurred. A call to an invalid function was attempted."
	else if SystemErrorCode == 0x1719		
		return "A parameter value is out of acceptable range."
	else if SystemErrorCode == 0x171A		
		return "A network error occurred while sending data to another node in the cluster. The number of bytes transmitted was less than required."
	else if SystemErrorCode == 0x171B		
		return "An invalid cluster registry operation was attempted."
	else if SystemErrorCode == 0x171C		
		return "An input string of characters is not properly terminated."
	else if SystemErrorCode == 0x171D		
		return "An input string of characters is not in a valid format for the data it represents."
	else if SystemErrorCode == 0x171E		
		return "An internal cluster error occurred. A cluster database transaction was attempted while a transaction was already in progress."
	else if SystemErrorCode == 0x171F		
		return "An internal cluster error occurred. There was an attempt to commit a cluster database transaction while no transaction was in progress."
	else if SystemErrorCode == 0x1720		
		return "An internal cluster error occurred. Data was not properly initialized."
	else if SystemErrorCode == 0x1721		
		return "An error occurred while reading from a stream of data. An unexpected number of bytes was returned."
	else if SystemErrorCode == 0x1722		
		return "An error occurred while writing to a stream of data. The required number of bytes could not be written."
	else if SystemErrorCode == 0x1723		
		return "An error occurred while deserializing a stream of cluster data."
	else if SystemErrorCode == 0x1725		
		return "A quorum of cluster nodes was not present to form a cluster."
	else if SystemErrorCode == 0x1727		
		return "The cluster network is not valid for an IPv6 Tunnel resource. Check the configuration of the IP Address resource on which the IPv6 Tunnel resource depends."
	else if SystemErrorCode == 0x1728		
		return "Quorum resource cannot reside in the Available Storage group."
	else if SystemErrorCode == 0x1729		
		return "The dependencies for this resource are nested too deeply."
	else if SystemErrorCode == 0x172A		
		return "The call into the resource DLL raised an unhandled exception."
	else if SystemErrorCode == 0x172B		
		return "The RHS process failed to initialize."
	else if SystemErrorCode == 0x172C		
		return "The Failover Clustering feature is not installed on this node."
	else if SystemErrorCode == 0x172D		
		return "The resources must be online on the same node for this operation."
	else if SystemErrorCode == 0x172E		
		return "A new node can not be added since this cluster is already at its maximum number of nodes."
	else if SystemErrorCode == 0x172F		
		return "This cluster can not be created since the specified number of nodes exceeds the maximum allowed limit."
	else if SystemErrorCode == 0x1730		
		return "An attempt to use the specified cluster name failed because an enabled computer object with the given name already exists in the domain."
	else if SystemErrorCode == 0x1732		
		return "File share associated with file share witness resource cannot be hosted by this cluster or any of its nodes."
	else if SystemErrorCode == 0x1734		
		return "Only one instance of this resource type is allowed in the cluster."
	else if SystemErrorCode == 0x1735		
		return "Only one instance of this resource type is allowed per resource group."
	else if SystemErrorCode == 0x1736		
		return "The resource failed to come online due to the failure of one or more provider resources."
	else if SystemErrorCode == 0x1737		
		return "The resource has indicated that it cannot come online on any node."
	else if SystemErrorCode == 0x1738		
		return "The current operation cannot be performed on this group at this time."
	else if SystemErrorCode == 0x1739		
		return "The directory or file is not located on a cluster shared volume."
	else if SystemErrorCode == 0x173A		
		return "The Security Descriptor does not meet the requirements for a cluster."
	else if SystemErrorCode == 0x173B		
		return "There is one or more shared volumes resources configured in the cluster. Those resources must be moved to available storage in order for operation to succeed."
	else if SystemErrorCode == 0x173C		
		return "This group or resource cannot be directly manipulated. Use shared volume APIs to perform desired operation."
	else if SystemErrorCode == 0x173D		
		return "Back up is in progress. Please wait for backup completion before trying this operation again."
	else if SystemErrorCode == 0x173E		
		return "The path does not belong to a cluster shared volume."
	else if SystemErrorCode == 0x173F		
		return "The cluster shared volume is not locally mounted on this node."
	else if SystemErrorCode == 0x1740		
		return "The cluster watchdog is terminating."
	else if SystemErrorCode == 0x1741		
		return "A resource vetoed a move between two nodes because they are incompatible."
	else if SystemErrorCode == 0x1743		
		return "The resource vetoed the call."
	else if SystemErrorCode == 0x1744		
		return "Resource could not start or run because it could not reserve sufficient system resources."
	else if SystemErrorCode == 0x1745		
		return "A resource vetoed a move between two nodes because the destination currently does not have enough resources to complete the operation."
	else if SystemErrorCode == 0x1746		
		return "A resource vetoed a move between two nodes because the source currently does not have enough resources to complete the operation."
	else if SystemErrorCode == 0x1747		
		return "The requested operation can not be completed because the group is queued for an operation."
	else if SystemErrorCode == 0x1748		
		return "The requested operation can not be completed because a resource has locked status."
	else if SystemErrorCode == 0x1749		
		return "The resource cannot move to another node because a cluster shared volume vetoed the operation."
	else if SystemErrorCode == 0x174B		
		return "Clustered storage is not connected to the node."
	else if SystemErrorCode == 0x174C		
		return "The disk is not configured in a way to be used with CSV. CSV disks must have at least one partition that is formatted with NTFS."
	else if SystemErrorCode == 0x174D		
		return "The resource must be part of the Available Storage group to complete this action."
	else if SystemErrorCode == 0x174E		
		return "CSVFS failed operation as volume is in redirected mode."
	else if SystemErrorCode == 0x174F		
		return "CSVFS failed operation as volume is not in redirected mode."
	else if SystemErrorCode == 0x1750		
		return "Cluster properties cannot be returned at this time."
	else if SystemErrorCode == 0x1751		
		return "The clustered disk resource contains software snapshot diff area that are not supported for Cluster Shared Volumes."
	else if SystemErrorCode == 0x1752		
		return "The operation cannot be completed because the resource is in maintenance mode."
	else if SystemErrorCode == 0x1753		
		return "The operation cannot be completed because of cluster affinity conflicts."
	else if SystemErrorCode == 0x1754		
		return "The operation cannot be completed because the resource is a replica virtual machine."
	else if SystemErrorCode == 0x1770		
		return "The specified file could not be encrypted."
	else if SystemErrorCode == 0x1771		
		return "The specified file could not be decrypted."
	else if SystemErrorCode == 0x1772		
		return "The specified file is encrypted and the user does not have the ability to decrypt it."
	else if SystemErrorCode == 0x1773		
		return "There is no valid encryption recovery policy configured for this system."
	else if SystemErrorCode == 0x1774		
		return "The required encryption driver is not loaded for this system."
	else if SystemErrorCode == 0x1775		
		return "The file was encrypted with a different encryption driver than is currently loaded."
	else if SystemErrorCode == 0x1776		
		return "There are no EFS keys defined for the user."
	else if SystemErrorCode == 0x1777		
		return "The specified file is not encrypted."
	else if SystemErrorCode == 0x1778		
		return "The specified file is not in the defined EFS export format."
	else if SystemErrorCode == 0x1779		
		return "The specified file is read only."
	else if SystemErrorCode == 0x177A		
		return "The directory has been disabled for encryption."
	else if SystemErrorCode == 0x177B		
		return "The server is not trusted for remote encryption operation."
	else if SystemErrorCode == 0x177C		
		return "Recovery policy configured for this system contains invalid recovery certificate."
	else if SystemErrorCode == 0x177D		
		return "The encryption algorithm used on the source file needs a bigger key buffer than the one on the destination file."
	else if SystemErrorCode == 0x177E		
		return "The disk partition does not support file encryption."
	else if SystemErrorCode == 0x177F		
		return "This machine is disabled for file encryption."
	else if SystemErrorCode == 0x1780		
		return "A newer system is required to decrypt this encrypted file."
	else if SystemErrorCode == 0x1781		
		return "The remote server sent an invalid response for a file being opened with Client Side Encryption."
	else if SystemErrorCode == 0x1782		
		return "Client Side Encryption is not supported by the remote server even though it claims to support it."
	else if SystemErrorCode == 0x1783		
		return "File is encrypted and should be opened in Client Side Encryption mode."
	else if SystemErrorCode == 0x17E6		
		return "The list of servers for this workgroup is not currently available."
	else if SystemErrorCode == 0x1838		
		return "The Task Scheduler service must be configured to run in the System account to function properly. Individual tasks may be configured to run in other accounts."
	else if SystemErrorCode == 0x19C8		
		return "Log service encountered an invalid log sector."
	else if SystemErrorCode == 0x19C9		
		return "Log service encountered a log sector with invalid block parity."
	else if SystemErrorCode == 0x19CA		
		return "Log service encountered a remapped log sector."
	else if SystemErrorCode == 0x19CB		
		return "Log service encountered a partial or incomplete log block."
	else if SystemErrorCode == 0x19CC		
		return "Log service encountered an attempt access data outside the active log range."
	else if SystemErrorCode == 0x19CD		
		return "Log service user marshalling buffers are exhausted."
	else if SystemErrorCode == 0x19CE		
		return "Log service encountered an attempt read from a marshalling area with an invalid read context."
	else if SystemErrorCode == 0x19CF		
		return "Log service encountered an invalid log restart area."
	else if SystemErrorCode == 0x19D0		
		return "Log service encountered an invalid log block version."
	else if SystemErrorCode == 0x19D1		
		return "Log service encountered an invalid log block."
	else if SystemErrorCode == 0x19D2		
		return "Log service encountered an attempt to read the log with an invalid read mode."
	else if SystemErrorCode == 0x19D3		
		return "Log service encountered a log stream with no restart area."
	else if SystemErrorCode == 0x19D4		
		return "Log service encountered a corrupted metadata file."
	else if SystemErrorCode == 0x19D5		
		return "Log service encountered a metadata file that could not be created by the log file system."
	else if SystemErrorCode == 0x19D6		
		return "Log service encountered a metadata file with inconsistent data."
	else if SystemErrorCode == 0x19D7		
		return "Log service encountered an attempt to erroneous allocate or dispose reservation space."
	else if SystemErrorCode == 0x19D8		
		return "Log service cannot delete log file or file system container."
	else if SystemErrorCode == 0x19D9		
		return "Log service has reached the maximum allowable containers allocated to a log file."
	else if SystemErrorCode == 0x19DA		
		return "Log service has attempted to read or write backward past the start of the log."
	else if SystemErrorCode == 0x19DB		
		return "Log policy could not be installed because a policy of the same type is already present."
	else if SystemErrorCode == 0x19DC		
		return "Log policy in question was not installed at the time of the request."
	else if SystemErrorCode == 0x19DD		
		return "The installed set of policies on the log is invalid."
	else if SystemErrorCode == 0x19DE		
		return "A policy on the log in question prevented the operation from completing."
	else if SystemErrorCode == 0x19DF		
		return "Log space cannot be reclaimed because the log is pinned by the archive tail."
	else if SystemErrorCode == 0x19E0		
		return "Log record is not a record in the log file."
	else if SystemErrorCode == 0x19E1		
		return "Number of reserved log records or the adjustment of the number of reserved log records is invalid."
	else if SystemErrorCode == 0x19E2		
		return "Reserved log space or the adjustment of the log space is invalid."
	else if SystemErrorCode == 0x19E3		
		return "An new or existing archive tail or base of the active log is invalid."
	else if SystemErrorCode == 0x19E4		
		return "Log space is exhausted."
	else if SystemErrorCode == 0x19E5		
		return "The log could not be set to the requested size."
	else if SystemErrorCode == 0x19E7		
		return "The operation failed because the log is a dedicated log."
	else if SystemErrorCode == 0x19E8		
		return "The operation requires an archive context."
	else if SystemErrorCode == 0x19E9		
		return "Log archival is in progress."
	else if SystemErrorCode == 0x19EB		
		return "The log must have at least two containers before it can be read from or written to."
	else if SystemErrorCode == 0x19EC		
		return "A log client has already registered on the stream."
	else if SystemErrorCode == 0x19ED		
		return "A log client has not been registered on the stream."
	else if SystemErrorCode == 0x19EE		
		return "A request has already been made to handle the log full condition."
	else if SystemErrorCode == 0x19EF		
		return "Log service encountered an error when attempting to read from a log container."
	else if SystemErrorCode == 0x19F0		
		return "Log service encountered an error when attempting to write to a log container."
	else if SystemErrorCode == 0x19F1		
		return "Log service encountered an error when attempting open a log container."
	else if SystemErrorCode == 0x19F2		
		return "Log service encountered an invalid container state when attempting a requested action."
	else if SystemErrorCode == 0x19F3		
		return "Log service is not in the correct state to perform a requested action."
	else if SystemErrorCode == 0x19F4		
		return "Log space cannot be reclaimed because the log is pinned."
	else if SystemErrorCode == 0x19F5		
		return "Log metadata flush failed."
	else if SystemErrorCode == 0x19F6		
		return "Security on the log and its containers is inconsistent."
	else if SystemErrorCode == 0x19F8		
		return "The log is pinned due to reservation consuming most of the log space. Free some reserved records to make space available."
	else if SystemErrorCode == 0x1A2C		
		return "The transaction handle associated with this operation is not valid."
	else if SystemErrorCode == 0x1A2D		
		return "The requested operation was made in the context of a transaction that is no longer active."
	else if SystemErrorCode == 0x1A2E		
		return "The requested operation is not valid on the Transaction object in its current state."
	else if SystemErrorCode == 0x1A32		
		return "The Transaction Manager was unable to be successfully initialized. Transacted operations are not supported."
	else if SystemErrorCode == 0x1A33		
		return "The specified ResourceManager made no changes or updates to the resource under this transaction."
	else if SystemErrorCode == 0x1A34		
		return "The resource manager has attempted to prepare a transaction that it has not successfully joined."
	else if SystemErrorCode == 0x1A36		
		return "The RM tried to register a protocol that already exists."
	else if SystemErrorCode == 0x1A37		
		return "The attempt to propagate the Transaction failed."
	else if SystemErrorCode == 0x1A38		
		return "The requested propagation protocol was not registered as a CRM."
	else if SystemErrorCode == 0x1A39		
		return "The buffer passed in to PushTransaction or PullTransaction is not in a valid format."
	else if SystemErrorCode == 0x1A3A		
		return "The current transaction context associated with the thread is not a valid handle to a transaction object."
	else if SystemErrorCode == 0x1A45		
		return "Implicit transaction are not supported."
	else if SystemErrorCode == 0x1A46		
		return "The kernel transaction manager had to abort or forget the transaction because it blocked forward progress."
	else if SystemErrorCode == 0x1A48		
		return "This snapshot operation cannot continue because a transactional resource manager cannot be frozen in its current state.  Please try again."
	else if SystemErrorCode == 0x1A4A		
		return "The transaction does not have a superior enlistment."
	else if SystemErrorCode == 0x1A90		
		return "The function attempted to use a name that is reserved for use by another transaction."
	else if SystemErrorCode == 0x1A91		
		return "Transaction support within the specified resource manager is not started or was shut down due to an error."
	else if SystemErrorCode == 0x1A92		
		return "The metadata of the RM has been corrupted. The RM will not function."
	else if SystemErrorCode == 0x1A93		
		return "The specified directory does not contain a resource manager."
	else if SystemErrorCode == 0x1A95		
		return "The remote server or share does not support transacted file operations."
	else if SystemErrorCode == 0x1A96		
		return "The requested log size is invalid."
	else if SystemErrorCode == 0x1A98		
		return "The specified file miniversion was not found for this transacted file open."
	else if SystemErrorCode == 0x1A99		
		return "The specified file miniversion was found but has been invalidated. Most likely cause is a transaction savepoint rollback."
	else if SystemErrorCode == 0x1A9A		
		return "A miniversion may only be opened in the context of the transaction that created it."
	else if SystemErrorCode == 0x1A9B		
		return "It is not possible to open a miniversion with modify access."
	else if SystemErrorCode == 0x1A9C		
		return "It is not possible to create any more miniversions for this stream."
	else if SystemErrorCode == 0x1A9E		
		return "The remote server sent mismatching version number or Fid for a file opened with transactions."
	else if SystemErrorCode == 0x1A9F		
		return "The handle has been invalidated by a transaction. The most likely cause is the presence of memory mapping on a file or an open handle when the transaction ended or rolled back to savepoint."
	else if SystemErrorCode == 0x1AA0		
		return "There is no transaction metadata on the file."
	else if SystemErrorCode == 0x1AA1		
		return "The log data is corrupt."
	else if SystemErrorCode == 0x1AA3		
		return "The transaction outcome is unavailable because the resource manager responsible for it has disconnected."
	else if SystemErrorCode == 0x1AA4		
		return "The request was rejected because the enlistment in question is not a superior enlistment."
	else if SystemErrorCode == 0x1AA5		
		return "The transactional resource manager is already consistent. Recovery is not needed."
	else if SystemErrorCode == 0x1AA6		
		return "The transactional resource manager has already been started."
	else if SystemErrorCode == 0x1AA8		
		return "The operation cannot be performed because another transaction is depending on the fact that this property will not change."
	else if SystemErrorCode == 0x1AA9		
		return "The operation would involve a single file with two transactional resource managers and is therefore not allowed."
	else if SystemErrorCode == 0x1AAB		
		return "The operation would leave a transactional resource manager in an inconsistent state and is therefore not allowed."
	else if SystemErrorCode == 0x1AAC		
		return "The operation could not be completed because the transaction manager does not have a log."
	else if SystemErrorCode == 0x1AAD		
		return "A rollback could not be scheduled because a previously scheduled rollback has already executed or been queued for execution."
	else if SystemErrorCode == 0x1AAE		
		return "The transactional metadata attribute on the file or directory is corrupt and unreadable."
	else if SystemErrorCode == 0x1AAF		
		return "The encryption operation could not be completed because a transaction is active."
	else if SystemErrorCode == 0x1AB0		
		return "This object is not allowed to be opened in a transaction."
	else if SystemErrorCode == 0x1AB3		
		return "Transaction metadata is already present on this file and cannot be superseded."
	else if SystemErrorCode == 0x1AB4		
		return "A transaction scope could not be entered because the scope handler has not been initialized."
	else if SystemErrorCode == 0x1AB6		
		return "This file is open for modification in an unresolved transaction and may be opened for execute only by a transacted reader."
	else if SystemErrorCode == 0x1AB7		
		return "The request to thaw frozen transactions was ignored because transactions had not previously been frozen."
	else if SystemErrorCode == 0x1AB8		
		return "Transactions cannot be frozen because a freeze is already in progress."
	else if SystemErrorCode == 0x1AB9		
		return "The target volume is not a snapshot volume. This operation is only valid on a volume mounted as a snapshot."
	else if SystemErrorCode == 0x1ABA		
		return "The savepoint operation failed because files are open on the transaction. This is not permitted."
	else if SystemErrorCode == 0x1ABC		
		return "The sparse operation could not be completed because a transaction is active on the file."
	else if SystemErrorCode == 0x1ABD		
		return "The call to create a TransactionManager object failed because the Tm Identity stored in the logfile does not match the Tm Identity that was passed in as an argument."
	else if SystemErrorCode == 0x1ABF		
		return "The transactional resource manager cannot currently accept transacted work due to a transient condition such as low resources."
	else if SystemErrorCode == 0x1AC0		
		return "The transactional resource manager had too many tranactions outstanding that could not be aborted. The transactional resource manger has been shut down."
	else if SystemErrorCode == 0x1AC1		
		return "The operation could not be completed due to bad clusters on disk."
	else if SystemErrorCode == 0x1AC2		
		return "The compression operation could not be completed because a transaction is active on the file."
	else if SystemErrorCode == 0x1AC3		
		return "The operation could not be completed because the volume is dirty. Please run chkdsk and try again."
	else if SystemErrorCode == 0x1AC4		
		return "The link tracking operation could not be completed because a transaction is active."
	else if SystemErrorCode == 0x1AC5		
		return "This operation cannot be performed in a transaction."
	else if SystemErrorCode == 0x1AC6		
		return "The handle is no longer properly associated with its transaction.  It may have been opened in a transactional resource manager that was subsequently forced to restart.  Please close the handle and open a new one."
	else if SystemErrorCode == 0x1AC7		
		return "The specified operation could not be performed because the resource manager is not enlisted in the transaction."
	else if SystemErrorCode == 0x1B59		
		return "The specified session name is invalid."
	else if SystemErrorCode == 0x1B5A		
		return "The specified protocol driver is invalid."
	else if SystemErrorCode == 0x1B5B		
		return "The specified protocol driver was not found in the system path."
	else if SystemErrorCode == 0x1B5C		
		return "The specified terminal connection driver was not found in the system path."
	else if SystemErrorCode == 0x1B5D		
		return "A registry key for event logging could not be created for this session."
	else if SystemErrorCode == 0x1B5E		
		return "A service with the same name already exists on the system."
	else if SystemErrorCode == 0x1B5F		
		return "A close operation is pending on the session."
	else if SystemErrorCode == 0x1B60		
		return "There are no free output buffers available."
	else if SystemErrorCode == 0x1B61		
		return "The MODEM.INF file was not found."
	else if SystemErrorCode == 0x1B62		
		return "The modem name was not found in MODEM.INF."
	else if SystemErrorCode == 0x1B63		
		return "The modem did not accept the command sent to it. Verify that the configured modem name matches the attached modem."
	else if SystemErrorCode == 0x1B64		
		return "The modem did not respond to the command sent to it. Verify that the modem is properly cabled and powered on."
	else if SystemErrorCode == 0x1B65		
		return "Carrier detect has failed or carrier has been dropped due to disconnect."
	else if SystemErrorCode == 0x1B66		
		return "Dial tone not detected within the required time. Verify that the phone cable is properly attached and functional."
	else if SystemErrorCode == 0x1B67		
		return "Busy signal detected at remote site on callback."
	else if SystemErrorCode == 0x1B68		
		return "Voice detected at remote site on callback."
	else if SystemErrorCode == 0x1B69		
		return "Transport driver error."
	else if SystemErrorCode == 0x1B6E		
		return "The specified session cannot be found."
	else if SystemErrorCode == 0x1B6F		
		return "The specified session name is already in use."
	else if SystemErrorCode == 0x1B71		
		return "An attempt has been made to connect to a session whose video mode is not supported by the current client."
	else if SystemErrorCode == 0x1B7B		
		return "The application attempted to enable DOS graphics mode. DOS graphics mode is not supported."
	else if SystemErrorCode == 0x1B7D		
		return "Your interactive logon privilege has been disabled. Please contact your administrator."
	else if SystemErrorCode == 0x1B7E		
		return "The requested operation can be performed only on the system console. This is most often the result of a driver or system DLL requiring direct console access."
	else if SystemErrorCode == 0x1B80		
		return "The client failed to respond to the server connect message."
	else if SystemErrorCode == 0x1B81		
		return "Disconnecting the console session is not supported."
	else if SystemErrorCode == 0x1B82		
		return "Reconnecting a disconnected session to the console is not supported."
	else if SystemErrorCode == 0x1B84		
		return "The request to control another session remotely was denied."
	else if SystemErrorCode == 0x1B85		
		return "The requested session access is denied."
	else if SystemErrorCode == 0x1B89		
		return "The specified terminal connection driver is invalid."
	else if SystemErrorCode == 0x1B8A		
		return "The requested session cannot be controlled remotely. This may be because the session is disconnected or does not currently have a user logged on."
	else if SystemErrorCode == 0x1B8B		
		return "The requested session is not configured to allow remote control."
	else if SystemErrorCode == 0x1B8C		
		return "Your request to connect to this Terminal Server has been rejected. Your Terminal Server client license number is currently being used by another user. Please call your system administrator to obtain a unique license number."
	else if SystemErrorCode == 0x1B8D		
		return "Your request to connect to this Terminal Server has been rejected. Your Terminal Server client license number has not been entered for this copy of the Terminal Server client. Please contact your system administrator."
	else if SystemErrorCode == 0x1B8E		
		return "The number of connections to this computer is limited and all connections are in use right now. Try connecting later or contact your system administrator."
	else if SystemErrorCode == 0x1B8F		
		return "The client you are using is not licensed to use this system. Your logon request is denied."
	else if SystemErrorCode == 0x1B90		
		return "The system license has expired. Your logon request is denied."
	else if SystemErrorCode == 0x1B91		
		return "Remote control could not be terminated because the specified session is not currently being remotely controlled."
	else if SystemErrorCode == 0x1B92		
		return "The remote control of the console was terminated because the display mode was changed. Changing the display mode in a remote control session is not supported."
	else if SystemErrorCode == 0x1B93		
		return "Activation has already been reset the maximum number of times for this installation. Your activation timer will not be cleared."
	else if SystemErrorCode == 0x1B94		
		return "Remote logins are currently disabled."
	else if SystemErrorCode == 0x1B95		
		return "You do not have the proper encryption level to access this Session."
	else if SystemErrorCode == 0x1B98		
		return "Unable to log you on because of an account restriction."
	else if SystemErrorCode == 0x1B9A		
		return "The Client Drive Mapping Service Has Connected on Terminal Connection."
	else if SystemErrorCode == 0x1B9B		
		return "The Client Drive Mapping Service Has Disconnected on Terminal Connection."
	else if SystemErrorCode == 0x1B9C		
		return "The Terminal Server security layer detected an error in the protocol stream and has disconnected the client."
	else if SystemErrorCode == 0x1B9D		
		return "The target session is incompatible with the current session."
	else if SystemErrorCode == 0x1F41		
		return "The file replication service API was called incorrectly."
	else if SystemErrorCode == 0x1F42		
		return "The file replication service cannot be started."
	else if SystemErrorCode == 0x1F43		
		return "The file replication service cannot be stopped."
	else if SystemErrorCode == 0x1F44		
		return "The file replication service API terminated the request. The event log may have more information."
	else if SystemErrorCode == 0x1F45		
		return "The file replication service terminated the request. The event log may have more information."
	else if SystemErrorCode == 0x1F46		
		return "The file replication service cannot be contacted. The event log may have more information."
	else if SystemErrorCode == 0x1F47		
		return "The file replication service cannot satisfy the request because the user has insufficient privileges. The event log may have more information."
	else if SystemErrorCode == 0x1F48		
		return "The file replication service cannot satisfy the request because authenticated RPC is not available. The event log may have more information."
	else if SystemErrorCode == 0x1F49		
		return "The file replication service cannot satisfy the request because the user has insufficient privileges on the domain controller. The event log may have more information."
	else if SystemErrorCode == 0x1F4A		
		return "The file replication service cannot satisfy the request because authenticated RPC is not available on the domain controller. The event log may have more information."
	else if SystemErrorCode == 0x1F4B		
		return "The file replication service cannot communicate with the file replication service on the domain controller. The event log may have more information."
	else if SystemErrorCode == 0x1F4C		
		return "The file replication service on the domain controller cannot communicate with the file replication service on this computer. The event log may have more information."
	else if SystemErrorCode == 0x1F4D		
		return "The file replication service cannot populate the system volume because of an internal error. The event log may have more information."
	else if SystemErrorCode == 0x1F4E		
		return "The file replication service cannot populate the system volume because of an internal timeout. The event log may have more information."
	else if SystemErrorCode == 0x1F4F		
		return "The file replication service cannot process the request. The system volume is busy with a previous request."
	else if SystemErrorCode == 0x1F50		
		return "The file replication service cannot stop replicating the system volume because of an internal error. The event log may have more information."
	else if SystemErrorCode == 0x1F51		
		return "The file replication service detected an invalid parameter."
	else if SystemErrorCode == 0x2009		
		return "The directory service evaluated group memberships locally."
	else if SystemErrorCode == 0x200A		
		return "The specified directory service attribute or value does not exist."
	else if SystemErrorCode == 0x200B		
		return "The attribute syntax specified to the directory service is invalid."
	else if SystemErrorCode == 0x200C		
		return "The attribute type specified to the directory service is not defined."
	else if SystemErrorCode == 0x200D		
		return "The specified directory service attribute or value already exists."
	else if SystemErrorCode == 0x200E		
		return "The directory service is busy."
	else if SystemErrorCode == 0x200F		
		return "The directory service is unavailable."
	else if SystemErrorCode == 0x2010		
		return "The directory service was unable to allocate a relative identifier."
	else if SystemErrorCode == 0x2011		
		return "The directory service has exhausted the pool of relative identifiers."
	else if SystemErrorCode == 0x2012		
		return "The requested operation could not be performed because the directory service is not the master for that type of operation."
	else if SystemErrorCode == 0x2013		
		return "The directory service was unable to initialize the subsystem that allocates relative identifiers."
	else if SystemErrorCode == 0x2014		
		return "The requested operation did not satisfy one or more constraints associated with the class of the object."
	else if SystemErrorCode == 0x2015		
		return "The directory service can perform the requested operation only on a leaf object."
	else if SystemErrorCode == 0x2016		
		return "The directory service cannot perform the requested operation on the RDN attribute of an object."
	else if SystemErrorCode == 0x2017		
		return "The directory service detected an attempt to modify the object class of an object."
	else if SystemErrorCode == 0x2019		
		return "Unable to contact the global catalog server."
	else if SystemErrorCode == 0x201A		
		return "The policy object is shared and can only be modified at the root."
	else if SystemErrorCode == 0x201B		
		return "The policy object does not exist."
	else if SystemErrorCode == 0x201C		
		return "The requested policy information is only in the directory service."
	else if SystemErrorCode == 0x201D		
		return "A domain controller promotion is currently active."
	else if SystemErrorCode == 0x201E		
		return "A domain controller promotion is not currently active."
	else if SystemErrorCode == 0x2020		
		return "An operations error occurred."
	else if SystemErrorCode == 0x2021		
		return "A protocol error occurred."
	else if SystemErrorCode == 0x2022		
		return "The time limit for this request was exceeded."
	else if SystemErrorCode == 0x2023		
		return "The size limit for this request was exceeded."
	else if SystemErrorCode == 0x2024		
		return "The administrative limit for this request was exceeded."
	else if SystemErrorCode == 0x2025		
		return "The compare response was false."
	else if SystemErrorCode == 0x2026		
		return "The compare response was true."
	else if SystemErrorCode == 0x2027		
		return "The requested authentication method is not supported by the server."
	else if SystemErrorCode == 0x2028		
		return "A more secure authentication method is required for this server."
	else if SystemErrorCode == 0x2029		
		return "Inappropriate authentication."
	else if SystemErrorCode == 0x202A		
		return "The authentication mechanism is unknown."
	else if SystemErrorCode == 0x202B		
		return "A referral was returned from the server."
	else if SystemErrorCode == 0x202C		
		return "The server does not support the requested critical extension."
	else if SystemErrorCode == 0x202D		
		return "This request requires a secure connection."
	else if SystemErrorCode == 0x202E		
		return "Inappropriate matching."
	else if SystemErrorCode == 0x202F		
		return "A constraint violation occurred."
	else if SystemErrorCode == 0x2030		
		return "There is no such object on the server."
	else if SystemErrorCode == 0x2031		
		return "There is an alias problem."
	else if SystemErrorCode == 0x2032		
		return "An invalid dn syntax has been specified."
	else if SystemErrorCode == 0x2033		
		return "The object is a leaf object."
	else if SystemErrorCode == 0x2034		
		return "There is an alias dereferencing problem."
	else if SystemErrorCode == 0x2035		
		return "The server is unwilling to process the request."
	else if SystemErrorCode == 0x2036		
		return "A loop has been detected."
	else if SystemErrorCode == 0x2037		
		return "There is a naming violation."
	else if SystemErrorCode == 0x2038		
		return "The result set is too large."
	else if SystemErrorCode == 0x2039		
		return "The operation affects multiple DSAs."
	else if SystemErrorCode == 0x203A		
		return "The server is not operational."
	else if SystemErrorCode == 0x203B		
		return "A local error has occurred."
	else if SystemErrorCode == 0x203C		
		return "An encoding error has occurred."
	else if SystemErrorCode == 0x203D		
		return "A decoding error has occurred."
	else if SystemErrorCode == 0x203E		
		return "The search filter cannot be recognized."
	else if SystemErrorCode == 0x203F		
		return "One or more parameters are illegal."
	else if SystemErrorCode == 0x2040		
		return "The specified method is not supported."
	else if SystemErrorCode == 0x2041		
		return "No results were returned."
	else if SystemErrorCode == 0x2042		
		return "The specified control is not supported by the server."
	else if SystemErrorCode == 0x2043		
		return "A referral loop was detected by the client."
	else if SystemErrorCode == 0x2044		
		return "The preset referral limit was exceeded."
	else if SystemErrorCode == 0x2045		
		return "The search requires a SORT control."
	else if SystemErrorCode == 0x2046		
		return "The search results exceed the offset range specified."
	else if SystemErrorCode == 0x206D		
		return "The root object must be the head of a naming context. The root object cannot have an instantiated parent."
	else if SystemErrorCode == 0x206E		
		return "The add replica operation cannot be performed. The naming context must be writeable in order to create the replica."
	else if SystemErrorCode == 0x206F		
		return "A reference to an attribute that is not defined in the schema occurred."
	else if SystemErrorCode == 0x2070		
		return "The maximum size of an object has been exceeded."
	else if SystemErrorCode == 0x2071		
		return "An attempt was made to add an object to the directory with a name that is already in use."
	else if SystemErrorCode == 0x2072		
		return "An attempt was made to add an object of a class that does not have an RDN defined in the schema."
	else if SystemErrorCode == 0x2073		
		return "An attempt was made to add an object using an RDN that is not the RDN defined in the schema."
	else if SystemErrorCode == 0x2074		
		return "None of the requested attributes were found on the objects."
	else if SystemErrorCode == 0x2075		
		return "The user buffer is too small."
	else if SystemErrorCode == 0x2076		
		return "The attribute specified in the operation is not present on the object."
	else if SystemErrorCode == 0x2077		
		return "Illegal modify operation. Some aspect of the modification is not permitted."
	else if SystemErrorCode == 0x2078		
		return "The specified object is too large."
	else if SystemErrorCode == 0x2079		
		return "The specified instance type is not valid."
	else if SystemErrorCode == 0x207A		
		return "The operation must be performed at a master DSA."
	else if SystemErrorCode == 0x207B		
		return "The object class attribute must be specified."
	else if SystemErrorCode == 0x207C		
		return "A required attribute is missing."
	else if SystemErrorCode == 0x207D		
		return "An attempt was made to modify an object to include an attribute that is not legal for its class."
	else if SystemErrorCode == 0x207E		
		return "The specified attribute is already present on the object."
	else if SystemErrorCode == 0x2081		
		return "Multiple values were specified for an attribute that can have only one value."
	else if SystemErrorCode == 0x2082		
		return "A value for the attribute was not in the acceptable range of values."
	else if SystemErrorCode == 0x2083		
		return "The specified value already exists."
	else if SystemErrorCode == 0x2084		
		return "The attribute cannot be removed because it is not present on the object."
	else if SystemErrorCode == 0x2085		
		return "The attribute value cannot be removed because it is not present on the object."
	else if SystemErrorCode == 0x2086		
		return "The specified root object cannot be a subref."
	else if SystemErrorCode == 0x2087		
		return "Chaining is not permitted."
	else if SystemErrorCode == 0x2088		
		return "Chained evaluation is not permitted."
	else if SystemErrorCode == 0x208A		
		return "Having a parent that is an alias is not permitted. Aliases are leaf objects."
	else if SystemErrorCode == 0x208C		
		return "The operation cannot be performed because child objects exist. This operation can only be performed on a leaf object."
	else if SystemErrorCode == 0x208D		
		return "Directory object not found."
	else if SystemErrorCode == 0x208E		
		return "The aliased object is missing."
	else if SystemErrorCode == 0x208F		
		return "The object name has bad syntax."
	else if SystemErrorCode == 0x2090		
		return "It is not permitted for an alias to refer to another alias."
	else if SystemErrorCode == 0x2091		
		return "The alias cannot be dereferenced."
	else if SystemErrorCode == 0x2092		
		return "The operation is out of scope."
	else if SystemErrorCode == 0x2093		
		return "The operation cannot continue because the object is in the process of being removed."
	else if SystemErrorCode == 0x2094		
		return "The DSA object cannot be deleted."
	else if SystemErrorCode == 0x2095		
		return "A directory service error has occurred."
	else if SystemErrorCode == 0x2096		
		return "The operation can only be performed on an internal master DSA object."
	else if SystemErrorCode == 0x2097		
		return "The object must be of class DSA."
	else if SystemErrorCode == 0x2098		
		return "Insufficient access rights to perform the operation."
	else if SystemErrorCode == 0x2099		
		return "The object cannot be added because the parent is not on the list of possible superiors."
	else if SystemErrorCode == 0x209B		
		return "The name has too many parts."
	else if SystemErrorCode == 0x209C		
		return "The name is too long."
	else if SystemErrorCode == 0x209D		
		return "The name value is too long."
	else if SystemErrorCode == 0x209E		
		return "The directory service encountered an error parsing a name."
	else if SystemErrorCode == 0x209F		
		return "The directory service cannot get the attribute type for a name."
	else if SystemErrorCode == 0x20A1		
		return "The security descriptor is too short."
	else if SystemErrorCode == 0x20A2		
		return "The security descriptor is invalid."
	else if SystemErrorCode == 0x20A3		
		return "Failed to create name for deleted object."
	else if SystemErrorCode == 0x20A4		
		return "The parent of a new subref must exist."
	else if SystemErrorCode == 0x20A5		
		return "The object must be a naming context."
	else if SystemErrorCode == 0x20A6		
		return "It is not permitted to add an attribute which is owned by the system."
	else if SystemErrorCode == 0x20A8		
		return "The schema object could not be found."
	else if SystemErrorCode == 0x20AA		
		return "The operation cannot be performed on a back link."
	else if SystemErrorCode == 0x20AB		
		return "The cross reference for the specified naming context could not be found."
	else if SystemErrorCode == 0x20AC		
		return "The operation could not be performed because the directory service is shutting down."
	else if SystemErrorCode == 0x20AD		
		return "The directory service request is invalid."
	else if SystemErrorCode == 0x20AE		
		return "The role owner attribute could not be read."
	else if SystemErrorCode == 0x20AF		
		return "The requested FSMO operation failed. The current FSMO holder could not be contacted."
	else if SystemErrorCode == 0x20B0		
		return "Modification of a DN across a naming context is not permitted."
	else if SystemErrorCode == 0x20B1		
		return "The attribute cannot be modified because it is owned by the system."
	else if SystemErrorCode == 0x20B2		
		return "Only the replicator can perform this function."
	else if SystemErrorCode == 0x20B3		
		return "The specified class is not defined."
	else if SystemErrorCode == 0x20B4		
		return "The specified class is not a subclass."
	else if SystemErrorCode == 0x20B5		
		return "The name reference is invalid."
	else if SystemErrorCode == 0x20B6		
		return "A cross reference already exists."
	else if SystemErrorCode == 0x20B7		
		return "It is not permitted to delete a master cross reference."
	else if SystemErrorCode == 0x20B8		
		return "Subtree notifications are only supported on NC heads."
	else if SystemErrorCode == 0x20B9		
		return "Notification filter is too complex."
	else if SystemErrorCode == 0x20CC		
		return "Schema update failed in recalculating validation cache."
	else if SystemErrorCode == 0x20CD		
		return "The tree deletion is not finished. The request must be made again to continue deleting the tree."
	else if SystemErrorCode == 0x20CE		
		return "The requested delete operation could not be performed."
	else if SystemErrorCode == 0x20CF		
		return "Cannot read the governs class identifier for the schema record."
	else if SystemErrorCode == 0x20D0		
		return "The attribute schema has bad syntax."
	else if SystemErrorCode == 0x20D1		
		return "The attribute could not be cached."
	else if SystemErrorCode == 0x20D2		
		return "The class could not be cached."
	else if SystemErrorCode == 0x20D3		
		return "The attribute could not be removed from the cache."
	else if SystemErrorCode == 0x20D4		
		return "The class could not be removed from the cache."
	else if SystemErrorCode == 0x20D5		
		return "The distinguished name attribute could not be read."
	else if SystemErrorCode == 0x20D6		
		return "No superior reference has been configured for the directory service. The directory service is therefore unable to issue referrals to objects outside this forest."
	else if SystemErrorCode == 0x20D7		
		return "The instance type attribute could not be retrieved."
	else if SystemErrorCode == 0x20D8		
		return "An internal error has occurred."
	else if SystemErrorCode == 0x20D9		
		return "A database error has occurred."
	else if SystemErrorCode == 0x20DA		
		return "The attribute GOVERNSID is missing."
	else if SystemErrorCode == 0x20DB		
		return "An expected attribute is missing."
	else if SystemErrorCode == 0x20DC		
		return "The specified naming context is missing a cross reference."
	else if SystemErrorCode == 0x20DD		
		return "A security checking error has occurred."
	else if SystemErrorCode == 0x20DE		
		return "The schema is not loaded."
	else if SystemErrorCode == 0x20DF		
		return "Schema allocation failed. Please check if the machine is running low on memory."
	else if SystemErrorCode == 0x20E0		
		return "Failed to obtain the required syntax for the attribute schema."
	else if SystemErrorCode == 0x20E1		
		return "The global catalog verification failed. The global catalog is not available or does not support the operation. Some part of the directory is currently not available."
	else if SystemErrorCode == 0x20E2		
		return "The replication operation failed because of a schema mismatch between the servers involved."
	else if SystemErrorCode == 0x20E3		
		return "The DSA object could not be found."
	else if SystemErrorCode == 0x20E4		
		return "The naming context could not be found."
	else if SystemErrorCode == 0x20E5		
		return "The naming context could not be found in the cache."
	else if SystemErrorCode == 0x20E6		
		return "The child object could not be retrieved."
	else if SystemErrorCode == 0x20E7		
		return "The modification was not permitted for security reasons."
	else if SystemErrorCode == 0x20E8		
		return "The operation cannot replace the hidden record."
	else if SystemErrorCode == 0x20E9		
		return "The hierarchy file is invalid."
	else if SystemErrorCode == 0x20EA		
		return "The attempt to build the hierarchy table failed."
	else if SystemErrorCode == 0x20EB		
		return "The directory configuration parameter is missing from the registry."
	else if SystemErrorCode == 0x20EC		
		return "The attempt to count the address book indices failed."
	else if SystemErrorCode == 0x20ED		
		return "The allocation of the hierarchy table failed."
	else if SystemErrorCode == 0x20EE		
		return "The directory service encountered an internal failure."
	else if SystemErrorCode == 0x20EF		
		return "The directory service encountered an unknown failure."
	else if SystemErrorCode == 0x20F4		
		return "The replication operation failed."
	else if SystemErrorCode == 0x20F5		
		return "An invalid parameter was specified for this replication operation."
	else if SystemErrorCode == 0x20F6		
		return "The directory service is too busy to complete the replication operation at this time."
	else if SystemErrorCode == 0x20F7		
		return "The distinguished name specified for this replication operation is invalid."
	else if SystemErrorCode == 0x20F8		
		return "The naming context specified for this replication operation is invalid."
	else if SystemErrorCode == 0x20F9		
		return "The distinguished name specified for this replication operation already exists."
	else if SystemErrorCode == 0x20FA		
		return "The replication system encountered an internal error."
	else if SystemErrorCode == 0x20FB		
		return "The replication operation encountered a database inconsistency."
	else if SystemErrorCode == 0x20FC		
		return "The server specified for this replication operation could not be contacted."
	else if SystemErrorCode == 0x20FD		
		return "The replication operation encountered an object with an invalid instance type."
	else if SystemErrorCode == 0x20FE		
		return "The replication operation failed to allocate memory."
	else if SystemErrorCode == 0x20FF		
		return "The replication operation encountered an error with the mail system."
	else if SystemErrorCode == 0x2100		
		return "The replication reference information for the target server already exists."
	else if SystemErrorCode == 0x2101		
		return "The replication reference information for the target server does not exist."
	else if SystemErrorCode == 0x2102		
		return "The naming context cannot be removed because it is replicated to another server."
	else if SystemErrorCode == 0x2103		
		return "The replication operation encountered a database error."
	else if SystemErrorCode == 0x2104		
		return "The naming context is in the process of being removed or is not replicated from the specified server."
	else if SystemErrorCode == 0x2105		
		return "Replication access was denied."
	else if SystemErrorCode == 0x2106		
		return "The requested operation is not supported by this version of the directory service."
	else if SystemErrorCode == 0x2107		
		return "The replication remote procedure call was cancelled."
	else if SystemErrorCode == 0x2108		
		return "The source server is currently rejecting replication requests."
	else if SystemErrorCode == 0x2109		
		return "The destination server is currently rejecting replication requests."
	else if SystemErrorCode == 0x210A		
		return "The replication operation failed due to a collision of object names."
	else if SystemErrorCode == 0x210B		
		return "The replication source has been reinstalled."
	else if SystemErrorCode == 0x210C		
		return "The replication operation failed because a required parent object is missing."
	else if SystemErrorCode == 0x210D		
		return "The replication operation was preempted."
	else if SystemErrorCode == 0x210E		
		return "The replication synchronization attempt was abandoned because of a lack of updates."
	else if SystemErrorCode == 0x210F		
		return "The replication operation was terminated because the system is shutting down."
	else if SystemErrorCode == 0x2110		
		return "Synchronization attempt failed because the destination DC is currently waiting to synchronize new partial attributes from source. This condition is normal if a recent schema change modified the partial attribute set. The destination partial attribute set is not a subset of source partial attribute set."
	else if SystemErrorCode == 0x2111		
		return "The replication synchronization attempt failed because a master replica attempted to sync from a partial replica."
	else if SystemErrorCode == 0x2113		
		return "The version of the directory service schema of the source forest is not compatible with the version of directory service on this computer."
	else if SystemErrorCode == 0x211B		
		return "Modification of a constructed attribute is not allowed."
	else if SystemErrorCode == 0x2120		
		return "The requested search operation is only supported for base searches."
	else if SystemErrorCode == 0x2121		
		return "The search failed to retrieve attributes from the database."
	else if SystemErrorCode == 0x2122		
		return "The schema update operation tried to add a backward link attribute that has no corresponding forward link."
	else if SystemErrorCode == 0x212A		
		return "Another operation which requires exclusive access to the PDC FSMO is already in progress."
	else if SystemErrorCode == 0x2130		
		return "Destination domain must be in native mode."
	else if SystemErrorCode == 0x2131		
		return "The operation cannot be performed because the server does not have an infrastructure container in the domain of interest."
	else if SystemErrorCode == 0x2134		
		return "The search flags for the attribute are invalid. The ANR bit is valid only on attributes of Unicode or Teletex strings."
	else if SystemErrorCode == 0x2135		
		return "Tree deletions starting at an object which has an NC head as a descendant are not allowed."
	else if SystemErrorCode == 0x2136		
		return "The directory service failed to lock a tree in preparation for a tree deletion because the tree was in use."
	else if SystemErrorCode == 0x2137		
		return "The directory service failed to identify the list of objects to delete while attempting a tree deletion."
	else if SystemErrorCode == 0x2139		
		return "Only an administrator can modify the membership list of an administrative group."
	else if SystemErrorCode == 0x213A		
		return "Cannot change the primary group ID of a domain controller account."
	else if SystemErrorCode == 0x213B		
		return "An attempt is made to modify the base schema."
	else if SystemErrorCode == 0x213D		
		return "Schema update is not allowed on this DC because the DC is not the schema FSMO Role Owner."
	else if SystemErrorCode == 0x2141		
		return "The specified group type is invalid."
	else if SystemErrorCode == 0x2144		
		return "A global group cannot have a local group as a member."
	else if SystemErrorCode == 0x2145		
		return "A global group cannot have a universal group as a member."
	else if SystemErrorCode == 0x2146		
		return "A universal group cannot have a local group as a member."
	else if SystemErrorCode == 0x2148		
		return "A local group cannot have another cross domain local group as a member."
	else if SystemErrorCode == 0x214C		
		return "The DSA operation is unable to proceed because of a DNS lookup failure."
	else if SystemErrorCode == 0x214E		
		return "The Security Descriptor attribute could not be read."
	else if SystemErrorCode == 0x2151		
		return "Security Account Manager needs to get the boot password."
	else if SystemErrorCode == 0x2152		
		return "Security Account Manager needs to get the boot key from floppy disk."
	else if SystemErrorCode == 0x2153		
		return "Directory Service cannot start."
	else if SystemErrorCode == 0x2154		
		return "Directory Services could not start."
	else if SystemErrorCode == 0x2155		
		return "The connection between client and server requires packet privacy or better."
	else if SystemErrorCode == 0x2156		
		return "The source domain may not be in the same forest as destination."
	else if SystemErrorCode == 0x2157		
		return "The destination domain must be in the forest."
	else if SystemErrorCode == 0x2158		
		return "The operation requires that destination domain auditing be enabled."
	else if SystemErrorCode == 0x215A		
		return "The source object must be a group or user."
	else if SystemErrorCode == 0x215C		
		return "The source and destination object must be of the same type."
	else if SystemErrorCode == 0x215E		
		return "Schema information could not be included in the replication request."
	else if SystemErrorCode == 0x215F		
		return "The replication operation could not be completed due to a schema incompatibility."
	else if SystemErrorCode == 0x2160		
		return "The replication operation could not be completed due to a previous schema incompatibility."
	else if SystemErrorCode == 0x2162		
		return "The requested domain could not be deleted because there exist domain controllers that still host this domain."
	else if SystemErrorCode == 0x2163		
		return "The requested operation can be performed only on a global catalog server."
	else if SystemErrorCode == 0x2164		
		return "A local group can only be a member of other local groups in the same domain."
	else if SystemErrorCode == 0x2165		
		return "Foreign security principals cannot be members of universal groups."
	else if SystemErrorCode == 0x2166		
		return "The attribute is not allowed to be replicated to the GC because of security reasons."
	else if SystemErrorCode == 0x2167		
		return "The checkpoint with the PDC could not be taken because there too many modifications being processed currently."
	else if SystemErrorCode == 0x2168		
		return "The operation requires that source domain auditing be enabled."
	else if SystemErrorCode == 0x2169		
		return "Security principal objects can only be created inside domain naming contexts."
	else if SystemErrorCode == 0x216B		
		return "A Filter was passed that uses constructed attributes."
	else if SystemErrorCode == 0x216C		
		return "The unicodePwd attribute value must be enclosed in double quotes."
	else if SystemErrorCode == 0x216D		
		return "Your computer could not be joined to the domain. You have exceeded the maximum number of computer accounts you are allowed to create in this domain. Contact your system administrator to have this limit reset or increased."
	else if SystemErrorCode == 0x2170		
		return "Critical Directory Service System objects cannot be deleted during tree delete operations. The tree delete may have been partially performed."
	else if SystemErrorCode == 0x2173		
		return "The version of the operating system is incompatible with the current AD DS forest functional level or AD LDS Configuration Set functional level. You must upgrade to a new version of the operating system before this server can become an AD DS Domain Controller or add an AD LDS Instance in this AD DS Forest or AD LDS Configuration Set."
	else if SystemErrorCode == 0x2174		
		return "The version of the operating system installed is incompatible with the current domain functional level. You must upgrade to a new version of the operating system before this server can become a domain controller in this domain."
	else if SystemErrorCode == 0x2175		
		return "The version of the operating system installed on this server no longer supports the current AD DS Forest functional level or AD LDS Configuration Set functional level. You must raise the AD DS Forest functional level or AD LDS Configuration Set functional level before this server can become an AD DS Domain Controller or an AD LDS Instance in this Forest or Configuration Set."
	else if SystemErrorCode == 0x2176		
		return "The version of the operating system installed on this server no longer supports the current domain functional level. You must raise the domain functional level before this server can become a domain controller in this domain."
	else if SystemErrorCode == 0x2177		
		return "The version of the operating system installed on this server is incompatible with the functional level of the domain or forest."
	else if SystemErrorCode == 0x217A		
		return "The sort order requested is not supported."
	else if SystemErrorCode == 0x217B		
		return "The requested name already exists as a unique identifier."
	else if SystemErrorCode == 0x217D		
		return "The database is out of version store."
	else if SystemErrorCode == 0x217E		
		return "Unable to continue operation because multiple conflicting controls were used."
	else if SystemErrorCode == 0x217F		
		return "Unable to find a valid security descriptor reference domain for this partition."
	else if SystemErrorCode == 0x2182		
		return "An account group cannot have a universal group as a member."
	else if SystemErrorCode == 0x2184		
		return "Move operations on objects in the schema naming context are not allowed."
	else if SystemErrorCode == 0x2185		
		return "A system flag has been set on the object and does not allow the object to be moved or renamed."
	else if SystemErrorCode == 0x2188		
		return "The requested action is not supported on standard server."
	else if SystemErrorCode == 0x2189		
		return "Could not access a partition of the directory service located on a remote server. Make sure at least one server is running for the partition in question."
	else if SystemErrorCode == 0x218B		
		return "The thread limit for this request was exceeded."
	else if SystemErrorCode == 0x218C		
		return "The Global catalog server is not in the closest site."
	else if SystemErrorCode == 0x218E		
		return "The Directory Service failed to enter single user mode."
	else if SystemErrorCode == 0x218F		
		return "The Directory Service cannot parse the script because of a syntax error."
	else if SystemErrorCode == 0x2190		
		return "The Directory Service cannot process the script because of an error."
	else if SystemErrorCode == 0x2192		
		return "The directory service binding must be renegotiated due to a change in the server extensions information."
	else if SystemErrorCode == 0x2193		
		return "Operation not allowed on a disabled cross ref."
	else if SystemErrorCode == 0x2197		
		return "The directory service failed to authorize the request."
	else if SystemErrorCode == 0x2198		
		return "The Directory Service cannot process the script because it is invalid."
	else if SystemErrorCode == 0x219A		
		return "A cross reference is in use locally with the same name."
	else if SystemErrorCode == 0x219C		
		return "Writeable NCs prevent this DC from demoting."
	else if SystemErrorCode == 0x219E		
		return "Insufficient attributes were given to create an object. This object may not exist because it may have been deleted and already garbage collected."
	else if SystemErrorCode == 0x219F		
		return "The group cannot be converted due to attribute restrictions on the requested group type."
	else if SystemErrorCode == 0x21A2		
		return "The FSMO role ownership could not be verified because its directory partition has not replicated successfully with at least one replication partner."
	else if SystemErrorCode == 0x21A3		
		return "The target container for a redirection of a well known object container cannot already be a special container."
	else if SystemErrorCode == 0x21A4		
		return "The Directory Service cannot perform the requested operation because a domain rename operation is in progress."
	else if SystemErrorCode == 0x21A5		
		return "The directory service detected a child partition below the requested partition name. The partition hierarchy must be created in a top down method."
	else if SystemErrorCode == 0x21A6		
		return "The directory service cannot replicate with this server because the time since the last replication with this server has exceeded the tombstone lifetime."
	else if SystemErrorCode == 0x21A7		
		return "The requested operation is not allowed on an object under the system container."
	else if SystemErrorCode == 0x21A8		
		return "The LDAP servers network send queue has filled up because the client is not processing the results of its requests fast enough. No more requests will be processed until the client catches up. If the client does not catch up then it will be disconnected."
	else if SystemErrorCode == 0x21A9		
		return "The scheduled replication did not take place because the system was too busy to execute the request within the schedule window. The replication queue is overloaded. Consider reducing the number of partners or decreasing the scheduled replication frequency."
	else if SystemErrorCode == 0x21AB		
		return "The site settings object for the specified site does not exist."
	else if SystemErrorCode == 0x21AC		
		return "The local account store does not contain secret material for the specified account."
	else if SystemErrorCode == 0x21AD		
		return "Could not find a writable domain controller in the domain."
	else if SystemErrorCode == 0x21AE		
		return "The server object for the domain controller does not exist."
	else if SystemErrorCode == 0x21AF		
		return "The NTDS Settings object for the domain controller does not exist."
	else if SystemErrorCode == 0x21B0		
		return "The requested search operation is not supported for ASQ searches."
	else if SystemErrorCode == 0x21B1		
		return "A required audit event could not be generated for the operation."
	else if SystemErrorCode == 0x21B2		
		return "The search flags for the attribute are invalid. The subtree index bit is valid only on single valued attributes."
	else if SystemErrorCode == 0x21B3		
		return "The search flags for the attribute are invalid. The tuple index bit is valid only on attributes of Unicode strings."
	else if SystemErrorCode == 0x21B4		
		return "The address books are nested too deeply. Failed to build the hierarchy table."
	else if SystemErrorCode == 0x21B6		
		return "The request to replicate secrets is denied."
	else if SystemErrorCode == 0x21B9		
		return "The replication operation failed because the required attributes of the local krbtgt object are missing."
	else if SystemErrorCode == 0x21BA		
		return "The domain name of the trusted domain already exists in the forest."
	else if SystemErrorCode == 0x21BB		
		return "The flat name of the trusted domain already exists in the forest."
	else if SystemErrorCode == 0x21BD		
		return "OID mapped groups cannot have members."
	else if SystemErrorCode == 0x21BE		
		return "The specified OID cannot be found."
	else if SystemErrorCode == 0x21BF		
		return "The replication operation failed because the target object referred by a link value is recycled."
	else if SystemErrorCode == 0x21C0		
		return "The redirect operation failed because the target object is in a NC different from the domain NC of the current domain controller."
	else if SystemErrorCode == 0x21C1		
		return "The functional level of the AD LDS configuration set cannot be lowered to the requested value."
	else if SystemErrorCode == 0x21C5		
		return "The undelete operation failed because the Sam Account Name or Additional Sam Account Name of the object being undeleted conflicts with an existing live object."
	else if SystemErrorCode == 0x2329		
		return "DNS server unable to interpret format."
	else if SystemErrorCode == 0x232A		
		return "DNS server failure."
	else if SystemErrorCode == 0x232B		
		return "DNS name does not exist."
	else if SystemErrorCode == 0x232C		
		return "DNS request not supported by name server."
	else if SystemErrorCode == 0x232D		
		return "DNS operation refused."
	else if SystemErrorCode == 0x2331		
		return "DNS server not authoritative for zone."
	else if SystemErrorCode == 0x2332		
		return "DNS name in update or prereq is not in zone."
	else if SystemErrorCode == 0x2338		
		return "DNS signature failed to verify."
	else if SystemErrorCode == 0x2339		
		return "DNS bad key."
	else if SystemErrorCode == 0x233A		
		return "DNS signature validity expired."
	else if SystemErrorCode == 0x238D		
		return "Only the DNS server acting as the key master for the zone may perform this operation."
	else if SystemErrorCode == 0x238E		
		return "This operation is not allowed on a zone that is signed or has signing keys."
	else if SystemErrorCode == 0x2391		
		return "The specified algorithm is not supported."
	else if SystemErrorCode == 0x2392		
		return "The specified key size is not supported."
	else if SystemErrorCode == 0x2393		
		return "One or more of the signing keys for a zone are not accessible to the DNS server. Zone signing will not be operational until this error is resolved."
	else if SystemErrorCode == 0x2396		
		return "An unexpected crypto error was encountered. Zone signing may not be operational until this error is resolved."
	else if SystemErrorCode == 0x2397		
		return "The DNS server encountered a signing key with an unknown version. Zone signing will not be operational until this error is resolved."
	else if SystemErrorCode == 0x2398		
		return "The specified key service provider cannot be opened by the DNS server."
	else if SystemErrorCode == 0x2399		
		return "The DNS server cannot accept any more signing keys with the specified algorithm and KSK flag value for this zone."
	else if SystemErrorCode == 0x239A		
		return "The specified rollover period is invalid."
	else if SystemErrorCode == 0x239B		
		return "The specified initial rollover offset is invalid."
	else if SystemErrorCode == 0x239C		
		return "The specified signing key is already in process of rolling over keys."
	else if SystemErrorCode == 0x239D		
		return "The specified signing key does not have a standby key to revoke."
	else if SystemErrorCode == 0x239F		
		return "This operation is not allowed on an active signing key."
	else if SystemErrorCode == 0x23A0		
		return "The specified signing key is already queued for rollover."
	else if SystemErrorCode == 0x23A1		
		return "This operation is not allowed on an unsigned zone."
	else if SystemErrorCode == 0x23A2		
		return "This operation could not be completed because the DNS server listed as the current key master for this zone is down or misconfigured. Resolve the problem on the current key master for this zone or use another DNS server to seize the key master role."
	else if SystemErrorCode == 0x23A3		
		return "The specified signature validity period is invalid."
	else if SystemErrorCode == 0x23A4		
		return "The specified NSEC3 iteration count is higher than allowed by the minimum key length used in the zone."
	else if SystemErrorCode == 0x23A5		
		return "This operation could not be completed because the DNS server has been configured with DNSSEC features disabled. Enable DNSSEC on the DNS server."
	else if SystemErrorCode == 0x23A6		
		return "This operation could not be completed because the XML stream received is empty or syntactically invalid."
	else if SystemErrorCode == 0x23A8		
		return "The specified signing key is not waiting for parental DS update."
	else if SystemErrorCode == 0x251D		
		return "No records found for given DNS query."
	else if SystemErrorCode == 0x251E		
		return "Bad DNS packet."
	else if SystemErrorCode == 0x251F		
		return "No DNS packet."
	else if SystemErrorCode == 0x2521		
		return "Unsecured DNS packet."
	else if SystemErrorCode == 0x2522		
		return "DNS query request is pending."
	else if SystemErrorCode == 0x254F		
		return "Invalid DNS type."
	else if SystemErrorCode == 0x2550		
		return "Invalid IP address."
	else if SystemErrorCode == 0x2551		
		return "Invalid property."
	else if SystemErrorCode == 0x2552		
		return "Try DNS operation again later."
	else if SystemErrorCode == 0x2553		
		return "Record for given name and type is not unique."
	else if SystemErrorCode == 0x2554		
		return "DNS name does not comply with RFC specifications."
	else if SystemErrorCode == 0x2558		
		return "DNS name contains an invalid character."
	else if SystemErrorCode == 0x2559		
		return "DNS name is entirely numeric."
	else if SystemErrorCode == 0x255A		
		return "The operation requested is not permitted on a DNS root server."
	else if SystemErrorCode == 0x255B		
		return "The record could not be created because this part of the DNS namespace has been delegated to another server."
	else if SystemErrorCode == 0x255C		
		return "The DNS server could not find a set of root hints."
	else if SystemErrorCode == 0x255D		
		return "The DNS server found root hints but they were not consistent across all adapters."
	else if SystemErrorCode == 0x255E		
		return "The specified value is too small for this parameter."
	else if SystemErrorCode == 0x255F		
		return "The specified value is too large for this parameter."
	else if SystemErrorCode == 0x2560		
		return "This operation is not allowed while the DNS server is loading zones in the background. Please try again later."
	else if SystemErrorCode == 0x2562		
		return "No data is allowed to exist underneath a DNAME record."
	else if SystemErrorCode == 0x2563		
		return "This operation requires credentials delegation."
	else if SystemErrorCode == 0x2564		
		return "Name resolution policy table has been corrupted. DNS resolution will fail until it is fixed. Contact your network administrator."
	else if SystemErrorCode == 0x2581		
		return "DNS zone does not exist."
	else if SystemErrorCode == 0x2582		
		return "DNS zone information not available."
	else if SystemErrorCode == 0x2583		
		return "Invalid operation for DNS zone."
	else if SystemErrorCode == 0x2584		
		return "Invalid DNS zone configuration."
	else if SystemErrorCode == 0x2587		
		return "DNS zone is locked."
	else if SystemErrorCode == 0x2588		
		return "DNS zone creation failed."
	else if SystemErrorCode == 0x2589		
		return "DNS zone already exists."
	else if SystemErrorCode == 0x258A		
		return "DNS automatic zone already exists."
	else if SystemErrorCode == 0x258B		
		return "Invalid DNS zone type."
	else if SystemErrorCode == 0x258C		
		return "Secondary DNS zone requires master IP address."
	else if SystemErrorCode == 0x258D		
		return "DNS zone not secondary."
	else if SystemErrorCode == 0x258E		
		return "Need secondary IP address."
	else if SystemErrorCode == 0x258F		
		return "WINS initialization failed."
	else if SystemErrorCode == 0x2590		
		return "Need WINS servers."
	else if SystemErrorCode == 0x2591		
		return "NBTSTAT initialization call failed."
	else if SystemErrorCode == 0x2593		
		return "A conditional forwarding zone already exists for that name."
	else if SystemErrorCode == 0x2594		
		return "This zone must be configured with one or more master DNS server IP addresses."
	else if SystemErrorCode == 0x2595		
		return "The operation cannot be performed because this zone is shut down."
	else if SystemErrorCode == 0x2596		
		return "This operation cannot be performed because the zone is currently being signed. Please try again later."
	else if SystemErrorCode == 0x25B3		
		return "Primary DNS zone requires datafile."
	else if SystemErrorCode == 0x25B4		
		return "Invalid datafile name for DNS zone."
	else if SystemErrorCode == 0x25B5		
		return "Failed to open datafile for DNS zone."
	else if SystemErrorCode == 0x25B6		
		return "Failed to write datafile for DNS zone."
	else if SystemErrorCode == 0x25B7		
		return "Failure while reading datafile for DNS zone."
	else if SystemErrorCode == 0x25E5		
		return "DNS record does not exist."
	else if SystemErrorCode == 0x25E6		
		return "DNS record format error."
	else if SystemErrorCode == 0x25E7		
		return "Node creation failure in DNS."
	else if SystemErrorCode == 0x25E8		
		return "Unknown DNS record type."
	else if SystemErrorCode == 0x25E9		
		return "DNS record timed out."
	else if SystemErrorCode == 0x25EA		
		return "Name not in DNS zone."
	else if SystemErrorCode == 0x25EB		
		return "CNAME loop detected."
	else if SystemErrorCode == 0x25EC		
		return "Node is a CNAME DNS record."
	else if SystemErrorCode == 0x25ED		
		return "A CNAME record already exists for given name."
	else if SystemErrorCode == 0x25EE		
		return "Record only at DNS zone root."
	else if SystemErrorCode == 0x25EF		
		return "DNS record already exists."
	else if SystemErrorCode == 0x25F0		
		return "Secondary DNS zone data error."
	else if SystemErrorCode == 0x25F1		
		return "Could not create DNS cache data."
	else if SystemErrorCode == 0x25F2		
		return "DNS name does not exist."
	else if SystemErrorCode == 0x25F4		
		return "DNS domain was undeleted."
	else if SystemErrorCode == 0x25F5		
		return "The directory service is unavailable."
	else if SystemErrorCode == 0x25F6		
		return "DNS zone already exists in the directory service."
	else if SystemErrorCode == 0x25F7		
		return "DNS server not creating or reading the boot file for the directory service integrated DNS zone."
	else if SystemErrorCode == 0x25F8		
		return "Node is a DNAME DNS record."
	else if SystemErrorCode == 0x25F9		
		return "A DNAME record already exists for given name."
	else if SystemErrorCode == 0x25FA		
		return "An alias loop has been detected with either CNAME or DNAME records."
	else if SystemErrorCode == 0x2618		
		return "DNS zone transfer failed."
	else if SystemErrorCode == 0x2619		
		return "Added local WINS server."
	else if SystemErrorCode == 0x2649		
		return "Secure update call needs to continue update request."
	else if SystemErrorCode == 0x267C		
		return "No DNS servers configured for local system."
	else if SystemErrorCode == 0x26AD		
		return "The specified directory partition does not exist."
	else if SystemErrorCode == 0x26AE		
		return "The specified directory partition already exists."
	else if SystemErrorCode == 0x26AF		
		return "This DNS server is not enlisted in the specified directory partition."
	else if SystemErrorCode == 0x26B0		
		return "This DNS server is already enlisted in the specified directory partition."
	else if SystemErrorCode == 0x26B1		
		return "The directory partition is not available at this time. Please wait a few minutes and try again."
	else if SystemErrorCode == 0x26B2		
		return "The operation failed because the domain naming master FSMO role could not be reached. The domain controller holding the domain naming master FSMO role is down or unable to service the request or is not running Windows Server 2003 or later."
	else if SystemErrorCode == 0x2714		
		return "A blocking operation was interrupted by a call to WSACancelBlockingCall."
	else if SystemErrorCode == 0x2719		
		return "The file handle supplied is not valid."
	else if SystemErrorCode == 0x271D		
		return "An attempt was made to access a socket in a way forbidden by its access permissions."
	else if SystemErrorCode == 0x271E		
		return "The system detected an invalid pointer address in attempting to use a pointer argument in a call."
	else if SystemErrorCode == 0x2726		
		return "An invalid argument was supplied."
	else if SystemErrorCode == 0x2728		
		return "Too many open sockets."
	else if SystemErrorCode == 0x2734		
		return "A blocking operation is currently executing."
	else if SystemErrorCode == 0x2736		
		return "An operation was attempted on something that is not a socket."
	else if SystemErrorCode == 0x2737		
		return "A required address was omitted from an operation on a socket."
	else if SystemErrorCode == 0x2739		
		return "A protocol was specified in the socket function call that does not support the semantics of the socket type requested."
	else if SystemErrorCode == 0x273C		
		return "The support for the specified socket type does not exist in this address family."
	else if SystemErrorCode == 0x273D		
		return "The attempted operation is not supported for the type of object referenced."
	else if SystemErrorCode == 0x273E		
		return "The protocol family has not been configured into the system or no implementation for it exists."
	else if SystemErrorCode == 0x273F		
		return "An address incompatible with the requested protocol was used."
	else if SystemErrorCode == 0x2741		
		return "The requested address is not valid in its context."
	else if SystemErrorCode == 0x2742		
		return "A socket operation encountered a dead network."
	else if SystemErrorCode == 0x2743		
		return "A socket operation was attempted to an unreachable network."
	else if SystemErrorCode == 0x2745		
		return "An established connection was aborted by the software in your host machine."
	else if SystemErrorCode == 0x2746		
		return "An existing connection was forcibly closed by the remote host."
	else if SystemErrorCode == 0x2747		
		return "An operation on a socket could not be performed because the system lacked sufficient buffer space or because a queue was full."
	else if SystemErrorCode == 0x2748		
		return "A connect request was made on an already connected socket."
	else if SystemErrorCode == 0x274A		
		return "A request to send or receive data was disallowed because the socket had already been shut down in that direction with a previous shutdown call."
	else if SystemErrorCode == 0x274B		
		return "Too many references to some kernel object."
	else if SystemErrorCode == 0x274D		
		return "No connection could be made because the target machine actively refused it."
	else if SystemErrorCode == 0x274E		
		return "Cannot translate name."
	else if SystemErrorCode == 0x274F		
		return "Name component or name was too long."
	else if SystemErrorCode == 0x2750		
		return "A socket operation failed because the destination host was down."
	else if SystemErrorCode == 0x2751		
		return "A socket operation was attempted to an unreachable host."
	else if SystemErrorCode == 0x2752		
		return "Cannot remove a directory that is not empty."
	else if SystemErrorCode == 0x2753		
		return "A Windows Sockets implementation may have a limit on the number of applications that may use it simultaneously."
	else if SystemErrorCode == 0x2754		
		return "Ran out of quota."
	else if SystemErrorCode == 0x2755		
		return "Ran out of disk quota."
	else if SystemErrorCode == 0x2756		
		return "File handle reference is no longer available."
	else if SystemErrorCode == 0x2757		
		return "Item is not available locally."
	else if SystemErrorCode == 0x276B		
		return "WSAStartup cannot function at this time because the underlying system it uses to provide network services is currently unavailable."
	else if SystemErrorCode == 0x276C		
		return "The Windows Sockets version requested is not supported."
	else if SystemErrorCode == 0x2775		
		return "Returned by WSARecv or WSARecvFrom to indicate the remote party has initiated a graceful shutdown sequence."
	else if SystemErrorCode == 0x2776		
		return "No more results can be returned by WSALookupServiceNext."
	else if SystemErrorCode == 0x2777		
		return "A call to WSALookupServiceEnd was made while this call was still processing. The call has been canceled."
	else if SystemErrorCode == 0x2778		
		return "The procedure call table is invalid."
	else if SystemErrorCode == 0x2779		
		return "The requested service provider is invalid."
	else if SystemErrorCode == 0x277A		
		return "The requested service provider could not be loaded or initialized."
	else if SystemErrorCode == 0x277B		
		return "A system call has failed."
	else if SystemErrorCode == 0x277C		
		return "No such service is known. The service cannot be found in the specified name space."
	else if SystemErrorCode == 0x277D		
		return "The specified class was not found."
	else if SystemErrorCode == 0x277E		
		return "No more results can be returned by WSALookupServiceNext."
	else if SystemErrorCode == 0x277F		
		return "A call to WSALookupServiceEnd was made while this call was still processing. The call has been canceled."
	else if SystemErrorCode == 0x2780		
		return "A database query failed because it was actively refused."
	else if SystemErrorCode == 0x2AF9		
		return "No such host is known."
	else if SystemErrorCode == 0x2AFA		
		return "This is usually a temporary error during hostname resolution and means that the local server did not receive a response from an authoritative server."
	else if SystemErrorCode == 0x2AFD		
		return "At least one reserve has arrived."
	else if SystemErrorCode == 0x2AFE		
		return "At least one path has arrived."
	else if SystemErrorCode == 0x2AFF		
		return "There are no senders."
	else if SystemErrorCode == 0x2B00		
		return "There are no receivers."
	else if SystemErrorCode == 0x2B01		
		return "Reserve has been confirmed."
	else if SystemErrorCode == 0x2B02		
		return "Error due to lack of resources."
	else if SystemErrorCode == 0x2B04		
		return "Unknown or conflicting style."
	else if SystemErrorCode == 0x2B05		
		return "Problem with some part of the filterspec or providerspecific buffer in general."
	else if SystemErrorCode == 0x2B06		
		return "Problem with some part of the flowspec."
	else if SystemErrorCode == 0x2B07		
		return "General QOS error."
	else if SystemErrorCode == 0x2B08		
		return "An invalid or unrecognized service type was found in the flowspec."
	else if SystemErrorCode == 0x2B09		
		return "An invalid or inconsistent flowspec was found in the QOS structure."
	else if SystemErrorCode == 0x2B0B		
		return "An invalid QOS filter style was used."
	else if SystemErrorCode == 0x2B0C		
		return "An invalid QOS filter type was used."
	else if SystemErrorCode == 0x2B0D		
		return "An incorrect number of QOS FILTERSPECs were specified in the FLOWDESCRIPTOR."
	else if SystemErrorCode == 0x2B0F		
		return "An incorrect number of flow descriptors was specified in the QOS structure."
	else if SystemErrorCode == 0x2B12		
		return "An invalid QOS flow descriptor was found in the flow descriptor list."
	else if SystemErrorCode == 0x2B13		
		return "An invalid or inconsistent flowspec was found in the QOS provider specific buffer."
	else if SystemErrorCode == 0x2B15		
		return "An invalid shape discard mode object was found in the QOS provider specific buffer."
	else if SystemErrorCode == 0x2B18		
		return "No such host is known securely."
	else if SystemErrorCode == 0x2B19		
		return "Name based IPSEC policy could not be added."
	else if SystemErrorCode == 0x32C8		
		return "The specified quick mode policy already exists."
	else if SystemErrorCode == 0x32C9		
		return "The specified quick mode policy was not found."
	else if SystemErrorCode == 0x32CA		
		return "The specified quick mode policy is being used."
	else if SystemErrorCode == 0x32CB		
		return "The specified main mode policy already exists."
	else if SystemErrorCode == 0x32CC		
		return "The specified main mode policy was not found."
	else if SystemErrorCode == 0x32CD		
		return "The specified main mode policy is being used."
	else if SystemErrorCode == 0x32CE		
		return "The specified main mode filter already exists."
	else if SystemErrorCode == 0x32CF		
		return "The specified main mode filter was not found."
	else if SystemErrorCode == 0x32D0		
		return "The specified transport mode filter already exists."
	else if SystemErrorCode == 0x32D1		
		return "The specified transport mode filter does not exist."
	else if SystemErrorCode == 0x32D2		
		return "The specified main mode authentication list exists."
	else if SystemErrorCode == 0x32D3		
		return "The specified main mode authentication list was not found."
	else if SystemErrorCode == 0x32D4		
		return "The specified main mode authentication list is being used."
	else if SystemErrorCode == 0x32D5		
		return "The specified default main mode policy was not found."
	else if SystemErrorCode == 0x32D6		
		return "The specified default main mode authentication list was not found."
	else if SystemErrorCode == 0x32D7		
		return "The specified default quick mode policy was not found."
	else if SystemErrorCode == 0x32D8		
		return "The specified tunnel mode filter exists."
	else if SystemErrorCode == 0x32D9		
		return "The specified tunnel mode filter was not found."
	else if SystemErrorCode == 0x32DA		
		return "The Main Mode filter is pending deletion."
	else if SystemErrorCode == 0x32DB		
		return "The transport filter is pending deletion."
	else if SystemErrorCode == 0x32DC		
		return "The tunnel filter is pending deletion."
	else if SystemErrorCode == 0x32DD		
		return "The Main Mode policy is pending deletion."
	else if SystemErrorCode == 0x32DE		
		return "The Main Mode authentication bundle is pending deletion."
	else if SystemErrorCode == 0x32DF		
		return "The Quick Mode policy is pending deletion."
	else if SystemErrorCode == 0x35E8		
		return "ERROR_IPSEC_IKE_NEG_STATUS_BEGIN"
	else if SystemErrorCode == 0x35E9		
		return "IKE authentication credentials are unacceptable."
	else if SystemErrorCode == 0x35EA		
		return "IKE security attributes are unacceptable."
	else if SystemErrorCode == 0x35EB		
		return "IKE Negotiation in progress."
	else if SystemErrorCode == 0x35EC		
		return "General processing error."
	else if SystemErrorCode == 0x35ED		
		return "Negotiation timed out."
	else if SystemErrorCode == 0x35EE		
		return "IKE failed to find valid machine certificate. Contact your Network Security Administrator about installing a valid certificate in the appropriate Certificate Store."
	else if SystemErrorCode == 0x35EF		
		return "IKE SA deleted by peer before establishment completed."
	else if SystemErrorCode == 0x35F0		
		return "IKE SA deleted before establishment completed."
	else if SystemErrorCode == 0x35F1		
		return "Negotiation request sat in Queue too long."
	else if SystemErrorCode == 0x35F2		
		return "Negotiation request sat in Queue too long."
	else if SystemErrorCode == 0x35F3		
		return "Negotiation request sat in Queue too long."
	else if SystemErrorCode == 0x35F4		
		return "Negotiation request sat in Queue too long."
	else if SystemErrorCode == 0x35F5		
		return "No response from peer."
	else if SystemErrorCode == 0x35F6		
		return "Negotiation took too long."
	else if SystemErrorCode == 0x35F7		
		return "Negotiation took too long."
	else if SystemErrorCode == 0x35F8		
		return "Unknown error occurred."
	else if SystemErrorCode == 0x35F9		
		return "Certificate Revocation Check failed."
	else if SystemErrorCode == 0x35FA		
		return "Invalid certificate key usage."
	else if SystemErrorCode == 0x35FB		
		return "Invalid certificate type."
	else if SystemErrorCode == 0x35FC		
		return "IKE negotiation failed because the machine certificate used does not have a private key. IPsec certificates require a private key. Contact your Network Security administrator about replacing with a certificate that has a private key."
	else if SystemErrorCode == 0x35FD		
		return "Simultaneous rekeys were detected."
	else if SystemErrorCode == 0x3600		
		return "Invalid header."
	else if SystemErrorCode == 0x3601		
		return "No policy configured."
	else if SystemErrorCode == 0x3602		
		return "Failed to verify signature."
	else if SystemErrorCode == 0x3603		
		return "Failed to authenticate using Kerberos."
	else if SystemErrorCode == 0x3605		
		return "Error processing error payload."
	else if SystemErrorCode == 0x3606		
		return "Error processing SA payload."
	else if SystemErrorCode == 0x3607		
		return "Error processing Proposal payload."
	else if SystemErrorCode == 0x3608		
		return "Error processing Transform payload."
	else if SystemErrorCode == 0x3609		
		return "Error processing KE payload."
	else if SystemErrorCode == 0x360A		
		return "Error processing ID payload."
	else if SystemErrorCode == 0x360B		
		return "Error processing Cert payload."
	else if SystemErrorCode == 0x360C		
		return "Error processing Certificate Request payload."
	else if SystemErrorCode == 0x360D		
		return "Error processing Hash payload."
	else if SystemErrorCode == 0x360E		
		return "Error processing Signature payload."
	else if SystemErrorCode == 0x360F		
		return "Error processing Nonce payload."
	else if SystemErrorCode == 0x3610		
		return "Error processing Notify payload."
	else if SystemErrorCode == 0x3611		
		return "Error processing Delete Payload."
	else if SystemErrorCode == 0x3612		
		return "Error processing VendorId payload."
	else if SystemErrorCode == 0x3613		
		return "Invalid payload received."
	else if SystemErrorCode == 0x3614		
		return "Soft SA loaded."
	else if SystemErrorCode == 0x3615		
		return "Soft SA torn down."
	else if SystemErrorCode == 0x3616		
		return "Invalid cookie received."
	else if SystemErrorCode == 0x3617		
		return "Peer failed to send valid machine certificate."
	else if SystemErrorCode == 0x3619		
		return "New policy invalidated SAs formed with old policy."
	else if SystemErrorCode == 0x361A		
		return "There is no available Main Mode IKE policy."
	else if SystemErrorCode == 0x361B		
		return "Failed to enabled TCB privilege."
	else if SystemErrorCode == 0x361C		
		return "Failed to load SECURITY.DLL."
	else if SystemErrorCode == 0x361D		
		return "Failed to obtain security function table dispatch address from SSPI."
	else if SystemErrorCode == 0x361E		
		return "Failed to query Kerberos package to obtain max token size."
	else if SystemErrorCode == 0x3621		
		return "Failed to obtain new SPI for the inbound SA from IPsec driver. The most common cause for this is that the driver does not have the correct filter. Check your policy to verify the filters."
	else if SystemErrorCode == 0x3622		
		return "Given filter is invalid."
	else if SystemErrorCode == 0x3623		
		return "Memory allocation failed."
	else if SystemErrorCode == 0x3625		
		return "Invalid policy."
	else if SystemErrorCode == 0x3626		
		return "Invalid DOI."
	else if SystemErrorCode == 0x3627		
		return "Invalid situation."
	else if SystemErrorCode == 0x362A		
		return "Error encrypting payload."
	else if SystemErrorCode == 0x362B		
		return "Error decrypting payload."
	else if SystemErrorCode == 0x362C		
		return "Policy match error."
	else if SystemErrorCode == 0x362D		
		return "Unsupported ID."
	else if SystemErrorCode == 0x362E		
		return "Hash verification failed."
	else if SystemErrorCode == 0x362F		
		return "Invalid hash algorithm."
	else if SystemErrorCode == 0x3630		
		return "Invalid hash size."
	else if SystemErrorCode == 0x3631		
		return "Invalid encryption algorithm."
	else if SystemErrorCode == 0x3632		
		return "Invalid authentication algorithm."
	else if SystemErrorCode == 0x3633		
		return "Invalid certificate signature."
	else if SystemErrorCode == 0x3634		
		return "Load failed."
	else if SystemErrorCode == 0x3635		
		return "Deleted via RPC call."
	else if SystemErrorCode == 0x3636		
		return "Temporary state created to perform reinitialization. This is not a real failure."
	else if SystemErrorCode == 0x3637		
		return "The lifetime value received in the Responder Lifetime Notify is below the Windows 2000 configured minimum value. Please fix the policy on the peer machine."
	else if SystemErrorCode == 0x3638		
		return "The recipient cannot handle version of IKE specified in the header."
	else if SystemErrorCode == 0x3639		
		return "Key length in certificate is too small for configured security requirements."
	else if SystemErrorCode == 0x363A		
		return "Max number of established MM SAs to peer exceeded."
	else if SystemErrorCode == 0x363B		
		return "IKE received a policy that disables negotiation."
	else if SystemErrorCode == 0x363C		
		return "Reached maximum quick mode limit for the main mode. New main mode will be started."
	else if SystemErrorCode == 0x363D		
		return "Main mode SA lifetime expired or peer sent a main mode delete."
	else if SystemErrorCode == 0x363E		
		return "Main mode SA assumed to be invalid because peer stopped responding."
	else if SystemErrorCode == 0x3640		
		return "Received unexpected message ID."
	else if SystemErrorCode == 0x3641		
		return "Received invalid authentication offers."
	else if SystemErrorCode == 0x3642		
		return "Sent DoS cookie notify to initiator."
	else if SystemErrorCode == 0x3643		
		return "IKE service is shutting down."
	else if SystemErrorCode == 0x3644		
		return "Could not verify binding between CGA address and certificate."
	else if SystemErrorCode == 0x3645		
		return "Error processing NatOA payload."
	else if SystemErrorCode == 0x3646		
		return "Parameters of the main mode are invalid for this quick mode."
	else if SystemErrorCode == 0x3647		
		return "Quick mode SA was expired by IPsec driver."
	else if SystemErrorCode == 0x3648		
		return "Too many dynamically added IKEEXT filters were detected."
	else if SystemErrorCode == 0x3649		
		return "ERROR_IPSEC_IKE_NEG_STATUS_END"
	else if SystemErrorCode == 0x364A		
		return "NAP reauth succeeded and must delete the dummy NAP IKEv2 tunnel."
	else if SystemErrorCode == 0x364B		
		return "Error in assigning inner IP address to initiator in tunnel mode."
	else if SystemErrorCode == 0x364C		
		return "Require configuration payload missing."
	else if SystemErrorCode == 0x364D		
		return "A negotiation running as the security principle who issued the connection is in progress."
	else if SystemErrorCode == 0x364F		
		return "Incoming SA request was dropped due to peer IP address rate limiting."
	else if SystemErrorCode == 0x3650		
		return "Peer does not support MOBIKE."
	else if SystemErrorCode == 0x3651		
		return "SA establishment is not authorized."
	else if SystemErrorCode == 0x3653		
		return "SA establishment is not authorized.  You may need to enter updated or different credentials such as a smartcard."
	else if SystemErrorCode == 0x3655		
		return "ERROR_IPSEC_IKE_NEG_STATUS_EXTENDED_END"
	else if SystemErrorCode == 0x3656		
		return "The SPI in the packet does not match a valid IPsec SA."
	else if SystemErrorCode == 0x3657		
		return "Packet was received on an IPsec SA whose lifetime has expired."
	else if SystemErrorCode == 0x3658		
		return "Packet was received on an IPsec SA that does not match the packet characteristics."
	else if SystemErrorCode == 0x3659		
		return "Packet sequence number replay check failed."
	else if SystemErrorCode == 0x365B		
		return "IPsec integrity check failed."
	else if SystemErrorCode == 0x365C		
		return "IPsec dropped a clear text packet."
	else if SystemErrorCode == 0x365D		
		return "IPsec dropped an incoming ESP packet in authenticated firewall mode. This drop is benign."
	else if SystemErrorCode == 0x365E		
		return "IPsec dropped a packet due to DoS throttling."
	else if SystemErrorCode == 0x3665		
		return "IPsec DoS Protection matched an explicit block rule."
	else if SystemErrorCode == 0x3666		
		return "IPsec DoS Protection received an IPsec specific multicast packet which is not allowed."
	else if SystemErrorCode == 0x3667		
		return "IPsec DoS Protection received an incorrectly formatted packet."
	else if SystemErrorCode == 0x3668		
		return "IPsec DoS Protection failed to look up state."
	else if SystemErrorCode == 0x3669		
		return "IPsec DoS Protection failed to create state because the maximum number of entries allowed by policy has been reached."
	else if SystemErrorCode == 0x366A		
		return "IPsec DoS Protection received an IPsec negotiation packet for a keying module which is not allowed by policy."
	else if SystemErrorCode == 0x366B		
		return "IPsec DoS Protection has not been enabled."
	else if SystemErrorCode == 0x366C		
		return "IPsec DoS Protection failed to create a per internal IP rate limit queue because the maximum number of queues allowed by policy has been reached."
	else if SystemErrorCode == 0x36B0		
		return "The requested section was not present in the activation context."
	else if SystemErrorCode == 0x36B2		
		return "The application binding data format is invalid."
	else if SystemErrorCode == 0x36B3		
		return "The referenced assembly is not installed on your system."
	else if SystemErrorCode == 0x36B4		
		return "The manifest file does not begin with the required tag and format information."
	else if SystemErrorCode == 0x36B5		
		return "The manifest file contains one or more syntax errors."
	else if SystemErrorCode == 0x36B6		
		return "The application attempted to activate a disabled activation context."
	else if SystemErrorCode == 0x36B7		
		return "The requested lookup key was not found in any active activation context."
	else if SystemErrorCode == 0x36B8		
		return "A component version required by the application conflicts with another component version already active."
	else if SystemErrorCode == 0x36B9		
		return "The type requested activation context section does not match the query API used."
	else if SystemErrorCode == 0x36BA		
		return "Lack of system resources has required isolated activation to be disabled for the current thread of execution."
	else if SystemErrorCode == 0x36BB		
		return "An attempt to set the process default activation context failed because the process default activation context was already set."
	else if SystemErrorCode == 0x36BC		
		return "The encoding group identifier specified is not recognized."
	else if SystemErrorCode == 0x36BD		
		return "The encoding requested is not recognized."
	else if SystemErrorCode == 0x36BE		
		return "The manifest contains a reference to an invalid URI."
	else if SystemErrorCode == 0x36BF		
		return "The application manifest contains a reference to a dependent assembly which is not installed."
	else if SystemErrorCode == 0x36C0		
		return "The manifest for an assembly used by the application has a reference to a dependent assembly which is not installed."
	else if SystemErrorCode == 0x36C1		
		return "The manifest contains an attribute for the assembly identity which is not valid."
	else if SystemErrorCode == 0x36C2		
		return "The manifest is missing the required default namespace specification on the assembly element."
	else if SystemErrorCode == 0x36C4		
		return "The private manifest probed has crossed a path with an unsupported reparse point."
	else if SystemErrorCode == 0x36C5		
		return "Two or more components referenced directly or indirectly by the application manifest have files by the same name."
	else if SystemErrorCode == 0x36C6		
		return "Two or more components referenced directly or indirectly by the application manifest have window classes with the same name."
	else if SystemErrorCode == 0x36C7		
		return "Two or more components referenced directly or indirectly by the application manifest have the same COM server CLSIDs."
	else if SystemErrorCode == 0x36C8		
		return "Two or more components referenced directly or indirectly by the application manifest have proxies for the same COM interface IIDs."
	else if SystemErrorCode == 0x36C9		
		return "Two or more components referenced directly or indirectly by the application manifest have the same COM type library TLBIDs."
	else if SystemErrorCode == 0x36CA		
		return "Two or more components referenced directly or indirectly by the application manifest have the same COM ProgIDs."
	else if SystemErrorCode == 0x36CB		
		return "Two or more components referenced directly or indirectly by the application manifest are different versions of the same component which is not permitted."
	else if SystemErrorCode == 0x36CD		
		return "The policy manifest contains one or more syntax errors."
	else if SystemErrorCode == 0x36FD		
		return "An HRESULT could not be translated to a corresponding Win32 error code."
	else if SystemErrorCode == 0x36FF		
		return "The supplied assembly identity is missing one or more attributes which must be present in this context."
	else if SystemErrorCode == 0x3700		
		return "The supplied assembly identity has one or more attribute names that contain characters not permitted in XML names."
	else if SystemErrorCode == 0x3701		
		return "The referenced assembly could not be found."
	else if SystemErrorCode == 0x3702		
		return "The activation context activation stack for the running thread of execution is corrupt."
	else if SystemErrorCode == 0x3703		
		return "The application isolation metadata for this process or thread has become corrupt."
	else if SystemErrorCode == 0x3704		
		return "The activation context being deactivated is not the most recently activated one."
	else if SystemErrorCode == 0x3705		
		return "The activation context being deactivated is not active for the current thread of execution."
	else if SystemErrorCode == 0x3706		
		return "The activation context being deactivated has already been deactivated."
	else if SystemErrorCode == 0x3707		
		return "A component used by the isolation facility has requested to terminate the process."
	else if SystemErrorCode == 0x3708		
		return "A kernel mode component is releasing a reference on an activation context."
	else if SystemErrorCode == 0x3709		
		return "The activation context of system default assembly could not be generated."
	else if SystemErrorCode == 0x370A		
		return "The value of an attribute in an identity is not within the legal range."
	else if SystemErrorCode == 0x370B		
		return "The name of an attribute in an identity is not within the legal range."
	else if SystemErrorCode == 0x370C		
		return "An identity contains two definitions for the same attribute."
	else if SystemErrorCode == 0x370F		
		return "The public key token does not correspond to the public key specified."
	else if SystemErrorCode == 0x3710		
		return "A substitution string had no mapping."
	else if SystemErrorCode == 0x3711		
		return "The component must be locked before making the request."
	else if SystemErrorCode == 0x3712		
		return "The component store has been corrupted."
	else if SystemErrorCode == 0x3713		
		return "An advanced installer failed during setup or servicing."
	else if SystemErrorCode == 0x3714		
		return "The character encoding in the XML declaration did not match the encoding used in the document."
	else if SystemErrorCode == 0x3715		
		return "The identities of the manifests are identical but their contents are different."
	else if SystemErrorCode == 0x3716		
		return "The component identities are different."
	else if SystemErrorCode == 0x3717		
		return "The assembly is not a deployment."
	else if SystemErrorCode == 0x3718		
		return "The file is not a part of the assembly."
	else if SystemErrorCode == 0x3719		
		return "The size of the manifest exceeds the maximum allowed."
	else if SystemErrorCode == 0x371A		
		return "The setting is not registered."
	else if SystemErrorCode == 0x371B		
		return "One or more required members of the transaction are not present."
	else if SystemErrorCode == 0x371C		
		return "The SMI primitive installer failed during setup or servicing."
	else if SystemErrorCode == 0x371D		
		return "A generic command executable returned a result that indicates failure."
	else if SystemErrorCode == 0x371E		
		return "A component is missing file verification information in its manifest."
	else if SystemErrorCode == 0x3A98		
		return "The specified channel path is invalid."
	else if SystemErrorCode == 0x3A99		
		return "The specified query is invalid."
	else if SystemErrorCode == 0x3A9A		
		return "The publisher metadata cannot be found in the resource."
	else if SystemErrorCode == 0x3A9C		
		return "The specified publisher name is invalid."
	else if SystemErrorCode == 0x3A9F		
		return "The specified channel could not be found. Check channel configuration."
	else if SystemErrorCode == 0x3AA1		
		return "The caller is trying to subscribe to a direct channel which is not allowed. The events for a direct channel go directly to a logfile and cannot be subscribed to."
	else if SystemErrorCode == 0x3AA2		
		return "Configuration error."
	else if SystemErrorCode == 0x3AA4		
		return "Query result is currently at an invalid position."
	else if SystemErrorCode == 0x3AA6		
		return "An expression can only be followed by a change of scope operation if it itself evaluates to a node set and is not already part of some other change of scope operation."
	else if SystemErrorCode == 0x3AAA		
		return "This data type is currently unsupported."
	else if SystemErrorCode == 0x3AAC		
		return "This operator is unsupported by this implementation of the filter."
	else if SystemErrorCode == 0x3AAD		
		return "The token encountered was unexpected."
	else if SystemErrorCode == 0x3AAE		
		return "The requested operation cannot be performed over an enabled direct channel. The channel must first be disabled before performing the requested operation."
	else if SystemErrorCode == 0x3AB1		
		return "The channel fails to activate."
	else if SystemErrorCode == 0x3AB2		
		return "The xpath expression exceeded supported complexity. Please symplify it or split it into two or more simple expressions."
	else if SystemErrorCode == 0x3AB4		
		return "The message id for the desired message could not be found."
	else if SystemErrorCode == 0x3AB7		
		return "The maximum number of replacements has been reached."
	else if SystemErrorCode == 0x3AB9		
		return "The locale specific resource for the desired message is not present."
	else if SystemErrorCode == 0x3ABA		
		return "The resource is too old to be compatible."
	else if SystemErrorCode == 0x3ABB		
		return "The resource is too new to be compatible."
	else if SystemErrorCode == 0x3ABD		
		return "The publisher has been disabled and its resource is not avaiable. This usually occurs when the publisher is in the process of being uninstalled or upgraded."
	else if SystemErrorCode == 0x3ABE		
		return "Attempted to create a numeric type that is outside of its valid range."
	else if SystemErrorCode == 0x3AE8		
		return "The subscription fails to activate."
	else if SystemErrorCode == 0x3AEB		
		return "The credential store that is used to save credentials is full."
	else if SystemErrorCode == 0x3AED		
		return "No active channel is found for the query."
	else if SystemErrorCode == 0x3AFC		
		return "The resource loader failed to find MUI file."
	else if SystemErrorCode == 0x3AFD		
		return "The resource loader failed to load MUI file because the file fail to pass validation."
	else if SystemErrorCode == 0x3AFE		
		return "The RC Manifest is corrupted with garbage data or unsupported version or missing required item."
	else if SystemErrorCode == 0x3AFF		
		return "The RC Manifest has invalid culture name."
	else if SystemErrorCode == 0x3B00		
		return "The RC Manifest has invalid ultimatefallback name."
	else if SystemErrorCode == 0x3B02		
		return "User stopped resource enumeration."
	else if SystemErrorCode == 0x3B03		
		return "UI language installation failed."
	else if SystemErrorCode == 0x3B04		
		return "Locale installation failed."
	else if SystemErrorCode == 0x3B06		
		return "A resource does not have default or neutral value."
	else if SystemErrorCode == 0x3B07		
		return "Invalid PRI config file."
	else if SystemErrorCode == 0x3B08		
		return "Invalid file type."
	else if SystemErrorCode == 0x3B09		
		return "Unknown qualifier."
	else if SystemErrorCode == 0x3B0A		
		return "Invalid qualifier value."
	else if SystemErrorCode == 0x3B0B		
		return "No Candidate found."
	else if SystemErrorCode == 0x3B0C		
		return "The ResourceMap or NamedResource has an item that does not have default or neutral resource.."
	else if SystemErrorCode == 0x3B0D		
		return "Invalid ResourceCandidate type."
	else if SystemErrorCode == 0x3B0E		
		return "Duplicate Resource Map."
	else if SystemErrorCode == 0x3B0F		
		return "Duplicate Entry."
	else if SystemErrorCode == 0x3B10		
		return "Invalid Resource Identifier."
	else if SystemErrorCode == 0x3B11		
		return "Filepath too long."
	else if SystemErrorCode == 0x3B12		
		return "Unsupported directory type."
	else if SystemErrorCode == 0x3B16		
		return "Invalid PRI File."
	else if SystemErrorCode == 0x3B17		
		return "NamedResource Not Found."
	else if SystemErrorCode == 0x3B1F		
		return "ResourceMap Not Found."
	else if SystemErrorCode == 0x3B20		
		return "Unsupported MRT profile type."
	else if SystemErrorCode == 0x3B21		
		return "Invalid qualifier operator."
	else if SystemErrorCode == 0x3B22		
		return "Unable to determine qualifier value or qualifier value has not been set."
	else if SystemErrorCode == 0x3B23		
		return "Automerge is enabled in the PRI file."
	else if SystemErrorCode == 0x3B24		
		return "Too many resources defined for package."
	else if SystemErrorCode == 0x3B62		
		return "The monitor does not comply with the MCCS specification it claims to support."
	else if SystemErrorCode == 0x3B65		
		return "An internal Monitor Configuration API error occurred."
	else if SystemErrorCode == 0x3B92		
		return "The requested system device cannot be identified due to multiple indistinguishable devices potentially matching the identification criteria."
	else if SystemErrorCode == 0x3BC3		
		return "The requested system device cannot be found."
	else if SystemErrorCode == 0x3BC4		
		return "Hash generation for the specified hash version and hash type is not enabled on the server."
	else if SystemErrorCode == 0x3BC5		
		return "The hash requested from the server is not available or no longer valid."
	else if SystemErrorCode == 0x3BD9		
		return "The secondary interrupt controller instance that manages the specified interrupt is not registered."
	else if SystemErrorCode == 0x3BDA		
		return "The information supplied by the GPIO client driver is invalid."
	else if SystemErrorCode == 0x3BDB		
		return "The version specified by the GPIO client driver is not supported."
	else if SystemErrorCode == 0x3BDC		
		return "The registration packet supplied by the GPIO client driver is not valid."
	else if SystemErrorCode == 0x3BDD		
		return "The requested operation is not suppported for the specified handle."
	else if SystemErrorCode == 0x3BDE		
		return "The requested connect mode conflicts with an existing mode on one or more of the specified pins."
	else if SystemErrorCode == 0x3BDF		
		return "The interrupt requested to be unmasked is not masked."
	else if SystemErrorCode == 0x3C28		
		return "The requested run level switch cannot be completed successfully."
	else if SystemErrorCode == 0x3C29		
		return "The service has an invalid run level setting. The run level for a service must not be higher than the run level of its dependent services."
	else if SystemErrorCode == 0x3C2A		
		return "The requested run level switch cannot be completed successfully since one or more services will not stop or restart within the specified timeout."
	else if SystemErrorCode == 0x3C2B		
		return "A run level switch agent did not respond within the specified timeout."
	else if SystemErrorCode == 0x3C2C		
		return "A run level switch is currently in progress."
	else if SystemErrorCode == 0x3C2D		
		return "One or more services failed to start during the service startup phase of a run level switch."
	else if SystemErrorCode == 0x3C8D		
		return "The task stop request cannot be completed immediately since task needs more time to shutdown."
	else if SystemErrorCode == 0x3CF0		
		return "Package could not be opened."
	else if SystemErrorCode == 0x3CF1		
		return "Package was not found."
	else if SystemErrorCode == 0x3CF2		
		return "Package data is invalid."
	else if SystemErrorCode == 0x3CF4		
		return "There is not enough disk space on your computer. Please free up some space and try again."
	else if SystemErrorCode == 0x3CF5		
		return "There was a problem downloading your product."
	else if SystemErrorCode == 0x3CF6		
		return "Package could not be registered."
	else if SystemErrorCode == 0x3CF7		
		return "Package could not be unregistered."
	else if SystemErrorCode == 0x3CF8		
		return "User cancelled the install request."
	else if SystemErrorCode == 0x3CF9		
		return "Install failed. Please contact your software vendor."
	else if SystemErrorCode == 0x3CFA		
		return "Removal failed. Please contact your software vendor."
	else if SystemErrorCode == 0x3CFC		
		return "The application cannot be started. Try reinstalling the application to fix the problem."
	else if SystemErrorCode == 0x3CFD		
		return "A Prerequisite for an install could not be satisfied."
	else if SystemErrorCode == 0x3CFE		
		return "The package repository is corrupted."
	else if SystemErrorCode == 0x3D00		
		return "The application cannot be started because it is currently updating."
	else if SystemErrorCode == 0x3D01		
		return "The package deployment operation is blocked by policy. Please contact your system administrator."
	else if SystemErrorCode == 0x3D02		
		return "The package could not be installed because resources it modifies are currently in use."
	else if SystemErrorCode == 0x3D03		
		return "The package could not be recovered because necessary data for recovery have been corrupted."
	else if SystemErrorCode == 0x3D06		
		return "The package could not be installed because a higher version of this package is already installed."
	else if SystemErrorCode == 0x3D07		
		return "An error in a system binary was detected. Try refreshing the PC to fix the problem."
	else if SystemErrorCode == 0x3D08		
		return "A corrupted CLR NGEN binary was detected on the system."
	else if SystemErrorCode == 0x3D09		
		return "The operation could not be resumed because necessary data for recovery have been corrupted."
	else if SystemErrorCode == 0x3D0A		
		return "The package could not be installed because the Windows Firewall service is not running. Enable the Windows Firewall service and try again."
	else if SystemErrorCode == 0x3D54		
		return "The process has no package identity."
	else if SystemErrorCode == 0x3D55		
		return "The package runtime information is corrupted."
	else if SystemErrorCode == 0x3D56		
		return "The package identity is corrupted."
	else if SystemErrorCode == 0x3D57		
		return "The process has no application identity."
	else if SystemErrorCode == 0x3DB8		
		return "Loading the state store failed."
	else if SystemErrorCode == 0x3DB9		
		return "Retrieving the state version for the application failed."
	else if SystemErrorCode == 0x3DBA		
		return "Setting the state version for the application failed."
	else if SystemErrorCode == 0x3DBB		
		return "Resetting the structured state of the application failed."
	else if SystemErrorCode == 0x3DBC		
		return "State Manager failed to open the container."
	else if SystemErrorCode == 0x3DBD		
		return "State Manager failed to create the container."
	else if SystemErrorCode == 0x3DBE		
		return "State Manager failed to delete the container."
	else if SystemErrorCode == 0x3DBF		
		return "State Manager failed to read the setting."
	else if SystemErrorCode == 0x3DC0		
		return "State Manager failed to write the setting."
	else if SystemErrorCode == 0x3DC1		
		return "State Manager failed to delete the setting."
	else if SystemErrorCode == 0x3DC2		
		return "State Manager failed to query the setting."
	else if SystemErrorCode == 0x3DC3		
		return "State Manager failed to read the composite setting."
	else if SystemErrorCode == 0x3DC4		
		return "State Manager failed to write the composite setting."
	else if SystemErrorCode == 0x3DC5		
		return "State Manager failed to enumerate the containers."
	else if SystemErrorCode == 0x3DC6		
		return "State Manager failed to enumerate the settings."
	else if SystemErrorCode == 0x3DC7		
		return "The size of the state manager composite setting value has exceeded the limit."
	else if SystemErrorCode == 0x3DC8		
		return "The size of the state manager setting value has exceeded the limit."
	else if SystemErrorCode == 0x3DC9		
		return "The length of the state manager setting name has exceeded the limit."
	else if SystemErrorCode == 0x3DCA		
		return "The length of the state manager container name has exceeded the limit."
}
