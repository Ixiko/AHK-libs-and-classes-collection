; ===============================================
; Posted by SKAN - https://www.autohotkey.com/boards/viewtopic.php?f=6&t=59882&p=252920&hilit=extended+file+properties#p252920
; Filexpro(sFile := "", p*)    - modified to be a bit smaller
; ===============================================
Filexpro(sFile := "", p*) {					; v.90 By SKAN on D1CC @ goo.gl/jyXFo9
	Local
	Static xDetails
	
	If ( sFile = "" ) {						; Deinit static variable
        xDetails := ""
        Return
    }
	
	fex := Map(), _FileExt := ""			; fex := {}
	
	If (!FileExist(sFile))
		return
	SplitPath sFile, _FileExt, _Dir, _Ext, _File, _Drv
	
	objShl := ComObjCreate("Shell.Application")
	objDir := objShl.NameSpace(_Dir), objItm := objDir.ParseName(_FileExt) 
	
	If ((VarSetCapacity(xDetails) = 0) Or (xDetails["_Dir"] != _Dir)) {	; Init static variable
        i:=-1, xDetails := Map(), xDetails.Capacity := 309, xDetails["_Dir"] := _Dir ; xDetails:={}, xDetails.SetCapacity(309)
		
        While ( i++ < 309 )
            xDetails[ objDir.GetDetailsOf(0,i) ] := i
        xDetails.Delete("")
    }
	
	i:=0,  nParams:=p.Length, fex.Capacity := nParams + 11 ; , fex.SetCapacity(nParams + 11) ; nParams:=p.Count()
	While (++i <= nParams And Prop := p[i]) {
        If (Dot:=InStr(Prop,".") And Prop := (Dot=1 ? "System":"") Prop) {
              fex[Prop] := objItm.ExtendedProperty(Prop)
              Continue 
        }
          
        If (xDetails.Has(Prop) And (PropNum := xDetails[Prop]) > -1) {
              fex[Prop] := ObjDir.GetDetailsOf(objItm,PropNum)
              Continue 
        }
    }
	
	fex.Capacity := 0 ; fex.SetCapacity(-1)
	
	If (fex.Count = 1)
		Return fex[p[1]]
	Else
		Return fex
}

; list of params for p*
; More common properties are at the bottom
; ===============================================
; System.Audio.ChannelCount
; System.Audio.Compression
; System.Audio.EncodingBitrate
; System.Audio.Format
; System.Audio.IsVariableBitRate
; System.Audio.PeakValue
; System.Audio.SampleRate
; System.Audio.SampleSize
; System.Audio.StreamName
; System.Audio.StreamNumber
; System.Calendar.Duration
; System.Calendar.IsOnline
; System.Calendar.IsRecurring
; System.Calendar.Location
; System.Calendar.OptionalAttendeeAddresses
; System.Calendar.OptionalAttendeeNames
; System.Calendar.OrganizerAddress
; System.Calendar.OrganizerName
; System.Calendar.ReminderTime
; System.Calendar.RequiredAttendeeAddresses
; System.Calendar.RequiredAttendeeNames
; System.Calendar.Resources
; System.Calendar.ResponseStatus
; System.Calendar.ShowTimeAs
; System.Calendar.ShowTimeAsText
; System.Communication.AccountName
; System.Communication.DateItemExpires
; System.Communication.Direction
; System.Communication.FollowupIconIndex
; System.Communication.HeaderItem
; System.Communication.PolicyTag
; System.Communication.SecurityFlags
; System.Communication.Suffix
; System.Communication.TaskStatus
; System.Communication.TaskStatusText
; System.Computer.DecoratedFreeSpace
; System.Contact.AccountPictureDynamicVideo
; System.Contact.AccountPictureLarge
; System.Contact.AccountPictureSmall
; System.Contact.Anniversary
; System.Contact.AssistantName
; System.Contact.AssistantTelephone
; System.Contact.Birthday
; System.Contact.BusinessAddress
; System.Contact.BusinessAddress1Country
; System.Contact.BusinessAddress1Locality
; System.Contact.BusinessAddress1PostalCode
; System.Contact.BusinessAddress1Region
; System.Contact.BusinessAddress1Street
; System.Contact.BusinessAddress2Country
; System.Contact.BusinessAddress2Locality
; System.Contact.BusinessAddress2PostalCode
; System.Contact.BusinessAddress2Region
; System.Contact.BusinessAddress2Street
; System.Contact.BusinessAddress3Country
; System.Contact.BusinessAddress3Locality
; System.Contact.BusinessAddress3PostalCode
; System.Contact.BusinessAddress3Region
; System.Contact.BusinessAddress3Street
; System.Contact.BusinessAddressCity
; System.Contact.BusinessAddressCountry
; System.Contact.BusinessAddressPostalCode
; System.Contact.BusinessAddressPostOfficeBox
; System.Contact.BusinessAddressState
; System.Contact.BusinessAddressStreet
; System.Contact.BusinessEmailAddresses
; System.Contact.BusinessFaxNumber
; System.Contact.BusinessHomePage
; System.Contact.BusinessTelephone
; System.Contact.CallbackTelephone
; System.Contact.CarTelephone
; System.Contact.Children
; System.Contact.CompanyMainTelephone
; System.Contact.ConnectedServiceDisplayName
; System.Contact.ConnectedServiceIdentities
; System.Contact.ConnectedServiceName
; System.Contact.ConnectedServiceSupportedActions
; System.Contact.DataSuppliers
; System.Contact.Department
; System.Contact.DisplayBusinessPhoneNumbers
; System.Contact.DisplayHomePhoneNumbers
; System.Contact.DisplayMobilePhoneNumbers
; System.Contact.DisplayOtherPhoneNumbers
; System.Contact.EmailAddress
; System.Contact.EmailAddress2
; System.Contact.EmailAddress3
; System.Contact.EmailAddresses
; System.Contact.EmailName
; System.Contact.FileAsName
; System.Contact.FirstName
; System.Contact.FullName
; System.Contact.Gender
; System.Contact.GenderValue
; System.Contact.Hobbies
; System.Contact.HomeAddress
; System.Contact.HomeAddress1Country
; System.Contact.HomeAddress1Locality
; System.Contact.HomeAddress1PostalCode
; System.Contact.HomeAddress1Region
; System.Contact.HomeAddress1Street
; System.Contact.HomeAddress2Country
; System.Contact.HomeAddress2Locality
; System.Contact.HomeAddress2PostalCode
; System.Contact.HomeAddress2Region
; System.Contact.HomeAddress2Street
; System.Contact.HomeAddress3Country
; System.Contact.HomeAddress3Locality
; System.Contact.HomeAddress3PostalCode
; System.Contact.HomeAddress3Region
; System.Contact.HomeAddress3Street
; System.Contact.HomeAddressCity
; System.Contact.HomeAddressCountry
; System.Contact.HomeAddressPostalCode
; System.Contact.HomeAddressPostOfficeBox
; System.Contact.HomeAddressState
; System.Contact.HomeAddressStreet
; System.Contact.HomeEmailAddresses
; System.Contact.HomeFaxNumber
; System.Contact.HomeTelephone
; System.Contact.IMAddress
; System.Contact.Initials
; System.Contact.JA.CompanyNamePhonetic
; System.Contact.JA.FirstNamePhonetic
; System.Contact.JA.LastNamePhonetic
; System.Contact.JobInfo1CompanyAddress
; System.Contact.JobInfo1CompanyName
; System.Contact.JobInfo1Department
; System.Contact.JobInfo1Manager
; System.Contact.JobInfo1OfficeLocation
; System.Contact.JobInfo1Title
; System.Contact.JobInfo1YomiCompanyName
; System.Contact.JobInfo2CompanyAddress
; System.Contact.JobInfo2CompanyName
; System.Contact.JobInfo2Department
; System.Contact.JobInfo2Manager
; System.Contact.JobInfo2OfficeLocation
; System.Contact.JobInfo2Title
; System.Contact.JobInfo2YomiCompanyName
; System.Contact.JobInfo3CompanyAddress
; System.Contact.JobInfo3CompanyName
; System.Contact.JobInfo3Department
; System.Contact.JobInfo3Manager
; System.Contact.JobInfo3OfficeLocation
; System.Contact.JobInfo3Title
; System.Contact.JobInfo3YomiCompanyName
; System.Contact.JobTitle
; System.Contact.Label
; System.Contact.LastName
; System.Contact.MailingAddress
; System.Contact.MiddleName
; System.Contact.MobileTelephone
; System.Contact.NickName
; System.Contact.OfficeLocation
; System.Contact.OtherAddress
; System.Contact.OtherAddress1Country
; System.Contact.OtherAddress1Locality
; System.Contact.OtherAddress1PostalCode
; System.Contact.OtherAddress1Region
; System.Contact.OtherAddress1Street
; System.Contact.OtherAddress2Country
; System.Contact.OtherAddress2Locality
; System.Contact.OtherAddress2PostalCode
; System.Contact.OtherAddress2Region
; System.Contact.OtherAddress2Street
; System.Contact.OtherAddress3Country
; System.Contact.OtherAddress3Locality
; System.Contact.OtherAddress3PostalCode
; System.Contact.OtherAddress3Region
; System.Contact.OtherAddress3Street
; System.Contact.OtherAddressCity
; System.Contact.OtherAddressCountry
; System.Contact.OtherAddressPostalCode
; System.Contact.OtherAddressPostOfficeBox
; System.Contact.OtherAddressState
; System.Contact.OtherAddressStreet
; System.Contact.OtherEmailAddresses
; System.Contact.PagerTelephone
; System.Contact.PersonalTitle
; System.Contact.PhoneNumbersCanonical
; System.Contact.Prefix
; System.Contact.PrimaryAddressCity
; System.Contact.PrimaryAddressCountry
; System.Contact.PrimaryAddressPostalCode
; System.Contact.PrimaryAddressPostOfficeBox
; System.Contact.PrimaryAddressState
; System.Contact.PrimaryAddressStreet
; System.Contact.PrimaryEmailAddress
; System.Contact.PrimaryTelephone
; System.Contact.Profession
; System.Contact.SpouseName
; System.Contact.Suffix
; System.Contact.TelexNumber
; System.Contact.TTYTDDTelephone
; System.Contact.WebPage
; System.Contact.Webpage2
; System.Contact.Webpage3
; System.AcquisitionID
; System.ApplicationDefinedProperties
; System.ApplicationName
; System.AppZoneIdentifier
; System.Author
; System.CachedFileUpdaterContentIdForConflictResolution
; System.CachedFileUpdaterContentIdForStream
; System.Capacity
; System.Category
; System.Comment
; System.Company
; System.ComputerName
; System.ContainedItems
; System.ContentStatus
; System.ContentType
; System.Copyright
; System.CreatorAppId
; System.CreatorOpenWithUIOptions
; System.DataObjectFormat
; System.DateAccessed
; System.DateAcquired
; System.DateArchived
; System.DateCompleted
; System.DateCreated
; System.DateImported
; System.DateModified
; System.DefaultSaveLocationDisplay
; System.DueDate
; System.EndDate
; System.ExpandoProperties
; System.FileAllocationSize
; System.FileAttributes
; System.FileCount
; System.FileDescription
; System.FileExtension
; System.FileFRN
; System.FileName
; System.FileOfflineAvailabilityStatus
; System.FileOwner
; System.FilePlaceholderStatus
; System.FileVersion
; System.FindData
; System.FlagColor
; System.FlagColorText
; System.FlagStatus
; System.FlagStatusText
; System.FolderKind
; System.FolderNameDisplay
; System.FreeSpace
; System.FullText
; System.HighKeywords
; System.ImageParsingName
; System.Importance
; System.ImportanceText
; System.IsAttachment
; System.IsDefaultNonOwnerSaveLocation
; System.IsDefaultSaveLocation
; System.IsDeleted
; System.IsEncrypted
; System.IsFlagged
; System.IsFlaggedComplete
; System.IsIncomplete
; System.IsLocationSupported
; System.IsPinnedToNameSpaceTree
; System.IsRead
; System.IsSearchOnlyItem
; System.IsSendToTarget
; System.IsShared
; System.ItemAuthors
; System.ItemClassType
; System.ItemDate
; System.ItemFolderNameDisplay
; System.ItemFolderPathDisplay
; System.ItemFolderPathDisplayNarrow
; System.ItemName
; System.ItemNameDisplay
; System.ItemNameDisplayWithoutExtension
; System.ItemNamePrefix
; System.ItemNameSortOverride
; System.ItemParticipants
; System.ItemPathDisplay
; System.ItemPathDisplayNarrow
; System.ItemSubType
; System.ItemType
; System.ItemTypeText
; System.ItemUrl
; System.Keywords
; System.Kind
; System.KindText
; System.Language
; System.LastSyncError
; System.LastWriterPackageFamilyName
; System.LowKeywords
; System.MediumKeywords
; System.MileageInformation
; System.MIMEType
; System.Null
; System.OfflineAvailability
; System.OfflineStatus
; System.OriginalFileName
; System.OwnerSID
; System.ParentalRating
; System.ParentalRatingReason
; System.ParentalRatingsOrganization
; System.ParsingBindContext
; System.ParsingName
; System.ParsingPath
; System.PerceivedType
; System.PercentFull
; System.Priority
; System.PriorityText
; System.Project
; System.ProviderItemID
; System.Rating
; System.RatingText
; System.RemoteConflictingFile
; System.Sensitivity
; System.SensitivityText
; System.SFGAOFlags
; System.SharedWith
; System.ShareUserRating
; System.SharingStatus
; System.Shell.OmitFromView
; System.SimpleRating
; System.Size
; System.SoftwareUsed
; System.SourceItem
; System.SourcePackageFamilyName
; System.StartDate
; System.Status
; System.StorageProviderCallerVersionInformation
; System.StorageProviderError
; System.StorageProviderFileChecksum
; System.StorageProviderFileIdentifier
; System.StorageProviderFileRemoteUri
; System.StorageProviderFileVersion
; System.StorageProviderFileVersionWaterline
; System.StorageProviderId
; System.StorageProviderShareStatuses
; System.StorageProviderSharingStatus
; System.StorageProviderStatus
; System.Subject
; System.SyncTransferStatus
; System.Thumbnail
; System.ThumbnailCacheId
; System.ThumbnailStream
; System.Title
; System.TitleSortOverride
; System.TotalFileSize
; System.Trademarks
; System.TransferOrder
; System.TransferPosition
; System.TransferSize
; System.VolumeId
; System.ZoneIdentifier
; System.Device.PrinterURL
; System.DeviceInterface.Bluetooth.DeviceAddress
; System.DeviceInterface.Bluetooth.Flags
; System.DeviceInterface.Bluetooth.LastConnectedTime
; System.DeviceInterface.Bluetooth.Manufacturer
; System.DeviceInterface.Bluetooth.ModelNumber
; System.DeviceInterface.Bluetooth.ProductId
; System.DeviceInterface.Bluetooth.ProductVersion
; System.DeviceInterface.Bluetooth.ServiceGuid
; System.DeviceInterface.Bluetooth.VendorId
; System.DeviceInterface.Bluetooth.VendorIdSource
; System.DeviceInterface.Hid.IsReadOnly
; System.DeviceInterface.Hid.ProductId
; System.DeviceInterface.Hid.UsageId
; System.DeviceInterface.Hid.UsagePage
; System.DeviceInterface.Hid.VendorId
; System.DeviceInterface.Hid.VersionNumber
; System.DeviceInterface.PrinterDriverDirectory
; System.DeviceInterface.PrinterDriverName
; System.DeviceInterface.PrinterEnumerationFlag
; System.DeviceInterface.PrinterName
; System.DeviceInterface.PrinterPortName
; System.DeviceInterface.Proximity.SupportsNfc
; System.DeviceInterface.Serial.PortName
; System.DeviceInterface.Serial.UsbProductId
; System.DeviceInterface.Serial.UsbVendorId
; System.DeviceInterface.WinUsb.DeviceInterfaceClasses
; System.DeviceInterface.WinUsb.UsbClass
; System.DeviceInterface.WinUsb.UsbProductId
; System.DeviceInterface.WinUsb.UsbProtocol
; System.DeviceInterface.WinUsb.UsbSubClass
; System.DeviceInterface.WinUsb.UsbVendorId
; System.Devices.Aep.AepId
; System.Devices.Aep.Bluetooth.Cod.Major
; System.Devices.AepService.Bluetooth.CacheMode
; System.Devices.AepService.Bluetooth.ServiceGuid
; System.Devices.AepService.Bluetooth.TargetDevice
; System.Devices.Aep.Bluetooth.Cod.Minor
; System.Devices.Aep.Bluetooth.Cod.Services.Audio
; System.Devices.Aep.Bluetooth.Cod.Services.Capturing
; System.Devices.Aep.Bluetooth.Cod.Services.Information
; System.Devices.Aep.Bluetooth.Cod.Services.LimitedDiscovery
; System.Devices.Aep.Bluetooth.Cod.Services.Networking
; System.Devices.Aep.Bluetooth.Cod.Services.ObjectXfer
; System.Devices.Aep.Bluetooth.Cod.Services.Positioning
; System.Devices.Aep.Bluetooth.Cod.Services.Rendering
; System.Devices.Aep.Bluetooth.Cod.Services.Telephony
; System.Devices.Aep.Bluetooth.Le.AddressType
; System.Devices.Aep.Bluetooth.Le.Appearance
; System.Devices.Aep.Bluetooth.Le.Appearance.Category
; System.Devices.Aep.Bluetooth.Le.Appearance.Subcategory
; System.Devices.Aep.Bluetooth.Le.IsConnectable
; System.Devices.Aep.CanPair
; System.Devices.Aep.Category
; System.Devices.Aep.ContainerId
; System.Devices.Aep.DeviceAddress
; System.Devices.Aep.IsConnected
; System.Devices.Aep.IsPaired
; System.Devices.Aep.IsPresent
; System.Devices.Aep.Manufacturer
; System.Devices.Aep.ModelId
; System.Devices.Aep.ModelName
; System.Devices.Aep.PointOfService.ConnectionTypes
; System.Devices.Aep.ProtocolId
; System.Devices.Aep.SignalStrength
; System.Devices.AepContainer.CanPair
; System.Devices.AepContainer.Categories
; System.Devices.AepContainer.Children
; System.Devices.AepContainer.ContainerId
; System.Devices.AepContainer.DialProtocol.InstalledApplications
; System.Devices.AepContainer.IsPaired
; System.Devices.AepContainer.IsPresent
; System.Devices.AepContainer.Manufacturer
; System.Devices.AepContainer.ModelIds
; System.Devices.AepContainer.ModelName
; System.Devices.AepContainer.ProtocolIds
; System.Devices.AepContainer.SupportedUriSchemes
; System.Devices.AepContainer.SupportsAudio
; System.Devices.AepContainer.SupportsCapturing
; System.Devices.AepContainer.SupportsImages
; System.Devices.AepContainer.SupportsInformation
; System.Devices.AepContainer.SupportsLimitedDiscovery
; System.Devices.AepContainer.SupportsNetworking
; System.Devices.AepContainer.SupportsObjectTransfer
; System.Devices.AepContainer.SupportsPositioning
; System.Devices.AepContainer.SupportsRendering
; System.Devices.AepContainer.SupportsTelephony
; System.Devices.AepContainer.SupportsVideo
; System.Devices.AepService.AepId
; System.Devices.AepService.Bluetooth.GattService.CacheMode
; System.Devices.AepService.Bluetooth.GattService.Device
; System.Devices.AepService.Bluetooth.RfcommService.CacheMode
; System.Devices.AepService.Bluetooth.RfcommService.Device
; System.Devices.AepService.ContainerId
; System.Devices.AepService.FriendlyName
; System.Devices.AepService.IoT.ServiceInterfaces
; System.Devices.AepService.ParentAepIsPaired
; System.Devices.AepService.ProtocolId
; System.Devices.AepService.ServiceClassId
; System.Devices.AepService.ServiceId
; System.Devices.AppPackageFamilyName
; System.Devices.AudioDevice.Microphone.SensitivityInDbfs
; System.Devices.AudioDevice.Microphone.SignalToNoiseRatioInDb
; System.Devices.AudioDevice.RawProcessingSupported
; System.Devices.AudioDevice.SpeechProcessingSupported
; System.Devices.BatteryLife
; System.Devices.BatteryPlusCharging
; System.Devices.BatteryPlusChargingText
; System.Devices.Category
; System.Devices.CategoryGroup
; System.Devices.CategoryIds
; System.Devices.CategoryPlural
; System.Devices.ChargingState
; System.Devices.Children
; System.Devices.ClassGuid
; System.Devices.CompatibleIds
; System.Devices.Connected
; System.Devices.ContainerId
; System.Devices.DefaultTooltip
; System.Devices.DeviceCapabilities
; System.Devices.DeviceCharacteristics
; System.Devices.DeviceDescription1
; System.Devices.DeviceDescription2
; System.Devices.DeviceHasProblem
; System.Devices.DeviceInstanceId
; System.Devices.DeviceManufacturer
; System.Devices.DevObjectType
; System.Devices.DialProtocol.InstalledApplications
; System.Devices.DiscoveryMethod
; System.Devices.Dnssd.Domain
; System.Devices.Dnssd.FullName
; System.Devices.Dnssd.HostName
; System.Devices.Dnssd.InstanceName
; System.Devices.Dnssd.NetworkAdapterId
; System.Devices.Dnssd.PortNumber
; System.Devices.Dnssd.Priority
; System.Devices.Dnssd.ServiceName
; System.Devices.Dnssd.TextAttributes
; System.Devices.Dnssd.Ttl
; System.Devices.Dnssd.Weight
; System.Devices.FriendlyName
; System.Devices.FunctionPaths
; System.Devices.GlyphIcon
; System.Devices.HardwareIds
; System.Devices.Icon
; System.Devices.InLocalMachineContainer
; System.Devices.InterfaceClassGuid
; System.Devices.InterfaceEnabled
; System.Devices.InterfacePaths
; System.Devices.IpAddress
; System.Devices.IsDefault
; System.Devices.IsNetworkConnected
; System.Devices.IsShared
; System.Devices.IsSoftwareInstalling
; System.Devices.LaunchDeviceStageFromExplorer
; System.Devices.LocalMachine
; System.Devices.LocationPaths
; System.Devices.Manufacturer
; System.Devices.MetadataPath
; System.Devices.MicrophoneArray.Geometry
; System.Devices.MissedCalls
; System.Devices.ModelId
; System.Devices.ModelName
; System.Devices.ModelNumber
; System.Devices.NetworkedTooltip
; System.Devices.NetworkName
; System.Devices.NetworkType
; System.Devices.NewPictures
; System.Devices.Notification
; System.Devices.Notifications.LowBattery
; System.Devices.Notifications.MissedCall
; System.Devices.Notifications.NewMessage
; System.Devices.Notifications.NewVoicemail
; System.Devices.Notifications.StorageFull
; System.Devices.Notifications.StorageFullLinkText
; System.Devices.NotificationStore
; System.Devices.NotWorkingProperly
; System.Devices.Paired
; System.Devices.Parent
; System.Devices.PhysicalDeviceLocation
; System.Devices.PlaybackPositionPercent
; System.Devices.PlaybackState
; System.Devices.PlaybackTitle
; System.Devices.Present
; System.Devices.PresentationUrl
; System.Devices.PrimaryCategory
; System.Devices.RemainingDuration
; System.Devices.RestrictedInterface
; System.Devices.Roaming
; System.Devices.SafeRemovalRequired
; System.Devices.ServiceAddress
; System.Devices.ServiceId
; System.Devices.SharedTooltip
; System.Devices.SignalStrength
; System.Devices.SmartCards.ReaderKind
; System.Devices.Status
; System.Devices.Status1
; System.Devices.Status2
; System.Devices.StorageCapacity
; System.Devices.StorageFreeSpace
; System.Devices.StorageFreeSpacePercent
; System.Devices.TextMessages
; System.Devices.Voicemail
; System.Devices.WiaDeviceType
; System.Devices.WiFi.InterfaceGuid
; System.Devices.WiFiDirect.DeviceAddress
; System.Devices.WiFiDirect.GroupId
; System.Devices.WiFiDirect.InformationElements
; System.Devices.WiFiDirect.InterfaceAddress
; System.Devices.WiFiDirect.InterfaceGuid
; System.Devices.WiFiDirect.IsConnected
; System.Devices.WiFiDirect.IsLegacyDevice
; System.Devices.WiFiDirect.IsMiracastLcpSupported
; System.Devices.WiFiDirect.IsVisible
; System.Devices.WiFiDirect.MiracastVersion
; System.Devices.WiFiDirect.Services
; System.Devices.WiFiDirect.SupportedChannelList
; System.Devices.WiFiDirectServices.AdvertisementId
; System.Devices.WiFiDirectServices.RequestServiceInformation
; System.Devices.WiFiDirectServices.ServiceAddress
; System.Devices.WiFiDirectServices.ServiceConfigMethods
; System.Devices.WiFiDirectServices.ServiceInformation
; System.Devices.WiFiDirectServices.ServiceName
; System.Devices.WinPhone8CameraFlags
; System.Devices.Wwan.InterfaceGuid
; System.Storage.Portable
; System.Storage.RemovableMedia
; System.Storage.SystemCritical
; System.Document.ByteCount
; System.Document.CharacterCount
; System.Document.ClientID
; System.Document.Contributor
; System.Document.DateCreated
; System.Document.DatePrinted
; System.Document.DateSaved
; System.Document.Division
; System.Document.DocumentID
; System.Document.HiddenSlideCount
; System.Document.LastAuthor
; System.Document.LineCount
; System.Document.Manager
; System.Document.MultimediaClipCount
; System.Document.NoteCount
; System.Document.PageCount
; System.Document.ParagraphCount
; System.Document.PresentationFormat
; System.Document.RevisionNumber
; System.Document.Security
; System.Document.SlideCount
; System.Document.Template
; System.Document.TotalEditingTime
; System.Document.Version
; System.Document.WordCount
; System.DRM.DatePlayExpires
; System.DRM.DatePlayStarts
; System.DRM.Description
; System.DRM.IsDisabled
; System.DRM.IsProtected
; System.DRM.PlayCount
; System.Identity
; System.Identity.Blob
; System.Identity.DisplayName
; System.Identity.InternetSid
; System.Identity.IsMeIdentity
; System.Identity.KeyProviderContext
; System.Identity.KeyProviderName
; System.Identity.LogonStatusString
; System.Identity.PrimaryEmailAddress
; System.Identity.PrimarySid
; System.Identity.ProviderData
; System.Identity.ProviderID
; System.Identity.QualifiedUserName
; System.Identity.UniqueID
; System.Identity.UserName
; System.IdentityProvider.Name
; System.IdentityProvider.Picture
; System.Image.BitDepth
; System.Image.ColorSpace
; System.Image.CompressedBitsPerPixel
; System.Image.CompressedBitsPerPixelDenominator
; System.Image.CompressedBitsPerPixelNumerator
; System.Image.Compression
; System.Image.CompressionText
; System.Image.Dimensions
; System.Image.HorizontalResolution
; System.Image.HorizontalSize
; System.Image.ImageID
; System.Image.ResolutionUnit
; System.Image.VerticalResolution
; System.Image.VerticalSize
; System.GPS.Altitude
; System.GPS.AltitudeDenominator
; System.GPS.AltitudeNumerator
; System.GPS.AltitudeRef
; System.GPS.AreaInformation
; System.GPS.Date
; System.GPS.DestBearing
; System.GPS.DestBearingDenominator
; System.GPS.DestBearingNumerator
; System.GPS.DestBearingRef
; System.GPS.DestDistance
; System.GPS.DestDistanceDenominator
; System.GPS.DestDistanceNumerator
; System.GPS.DestDistanceRef
; System.GPS.DestLatitude
; System.GPS.DestLatitudeDenominator
; System.GPS.DestLatitudeNumerator
; System.GPS.DestLatitudeRef
; System.GPS.DestLongitude
; System.GPS.DestLongitudeDenominator
; System.GPS.DestLongitudeNumerator
; System.GPS.DestLongitudeRef
; System.GPS.Differential
; System.GPS.DOP
; System.GPS.DOPDenominator
; System.GPS.DOPNumerator
; System.GPS.ImgDirection
; System.GPS.ImgDirectionDenominator
; System.GPS.ImgDirectionNumerator
; System.GPS.ImgDirectionRef
; System.GPS.Latitude
; System.GPS.LatitudeDecimal
; System.GPS.LatitudeDenominator
; System.GPS.LatitudeNumerator
; System.GPS.LatitudeRef
; System.GPS.Longitude
; System.GPS.LongitudeDecimal
; System.GPS.LongitudeDenominator
; System.GPS.LongitudeNumerator
; System.GPS.LongitudeRef
; System.GPS.MapDatum
; System.GPS.MeasureMode
; System.GPS.ProcessingMethod
; System.GPS.Satellites
; System.GPS.Speed
; System.GPS.SpeedDenominator
; System.GPS.SpeedNumerator
; System.GPS.SpeedRef
; System.GPS.Status
; System.GPS.Track
; System.GPS.TrackDenominator
; System.GPS.TrackNumerator
; System.GPS.TrackRef
; System.GPS.VersionID
; System.History.VisitCount
; System.Journal.Contacts
; System.Journal.EntryType
; System.LayoutPattern.ContentViewModeForBrowse
; System.LayoutPattern.ContentViewModeForSearch
; System.History.SelectionCount
; System.History.TargetUrlHostName
; System.Link.Arguments
; System.Link.Comment
; System.Link.DateVisited
; System.Link.Description
; System.Link.FeedItemLocalId
; System.Link.Status
; System.Link.TargetExtension
; System.Link.TargetParsingPath
; System.Link.TargetSFGAOFlags
; System.Link.TargetUrlHostName
; System.Link.TargetUrlPath
; System.History.SelectionCount
; System.History.TargetUrlHostName
; System.Link.Arguments
; System.Link.Comment
; System.Link.DateVisited
; System.Link.Description
; System.Link.FeedItemLocalId
; System.Link.Status
; System.Link.TargetExtension
; System.Link.TargetParsingPath
; System.Link.TargetSFGAOFlags
; System.Link.TargetUrlHostName
; System.Link.TargetUrlPath
; System.Media.AuthorUrl
; System.Media.AverageLevel
; System.Media.ClassPrimaryID
; System.Media.ClassSecondaryID
; System.Media.CollectionGroupID
; System.Media.CollectionID
; System.Media.ContentDistributor
; System.Media.ContentID
; System.Media.CreatorApplication
; System.Media.CreatorApplicationVersion
; System.Media.DateEncoded
; System.Media.DateReleased
; System.Media.DlnaProfileID
; System.Media.Duration
; System.Media.DVDID
; System.Media.EncodedBy
; System.Media.EncodingSettings
; System.Media.EpisodeNumber
; System.Media.FrameCount
; System.Media.MCDI
; System.Media.MetadataContentProvider
; System.Media.Producer
; System.Media.PromotionUrl
; System.Media.ProtectionType
; System.Media.ProviderRating
; System.Media.ProviderStyle
; System.Media.Publisher
; System.Media.SeasonNumber
; System.Media.SeriesName
; System.Media.SubscriptionContentId
; System.Media.SubTitle
; System.Media.ThumbnailLargePath
; System.Media.ThumbnailLargeUri
; System.Media.ThumbnailSmallPath
; System.Media.ThumbnailSmallUri
; System.Media.UniqueFileIdentifier
; System.Media.UserNoAutoInfo
; System.Media.UserWebUrl
; System.Media.Writer
; System.Media.Year
; System.Message.AttachmentContents
; System.Message.AttachmentNames
; System.Message.BccAddress
; System.Message.BccName
; System.Message.CcAddress
; System.Message.CcName
; System.Message.ConversationID
; System.Message.ConversationIndex
; System.Message.DateReceived
; System.Message.DateSent
; System.Message.Flags
; System.Message.FromAddress
; System.Message.FromName
; System.Message.HasAttachments
; System.Message.IsFwdOrReply
; System.Message.MessageClass
; System.Message.Participants
; System.Message.ProofInProgress
; System.Message.SenderAddress
; System.Message.SenderName
; System.Message.Store
; System.Message.ToAddress
; System.Message.ToDoFlags
; System.Message.ToDoTitle
; System.Message.ToName
; System.Music.AlbumArtist
; System.Music.AlbumArtistSortOverride
; System.Music.AlbumID
; System.Music.AlbumTitle
; System.Music.AlbumTitleSortOverride
; System.Music.Artist
; System.Music.ArtistSortOverride
; System.Music.BeatsPerMinute
; System.Music.Composer
; System.Music.ComposerSortOverride
; System.Music.Conductor
; System.Music.ContentGroupDescription
; System.Music.DiscNumber
; System.Music.DisplayArtist
; System.Music.Genre
; System.Music.InitialKey
; System.Music.IsCompilation
; System.Music.Lyrics
; System.Music.Mood
; System.Music.PartOfSet
; System.Music.Period
; System.Music.SynchronizedLyrics
; System.Music.TrackNumber
; System.Note.Color
; System.Note.ColorText
; System.Photo.Aperture
; System.Photo.ApertureDenominator
; System.Photo.ApertureNumerator
; System.Photo.Brightness
; System.Photo.BrightnessDenominator
; System.Photo.BrightnessNumerator
; System.Photo.CameraManufacturer
; System.Photo.CameraModel
; System.Photo.CameraSerialNumber
; System.Photo.Contrast
; System.Photo.ContrastText
; System.Photo.DateTaken
; System.Photo.DigitalZoom
; System.Photo.DigitalZoomDenominator
; System.Photo.DigitalZoomNumerator
; System.Photo.Event
; System.Photo.EXIFVersion
; System.Photo.ExposureBias
; System.Photo.ExposureBiasDenominator
; System.Photo.ExposureBiasNumerator
; System.Photo.ExposureIndex
; System.Photo.ExposureIndexDenominator
; System.Photo.ExposureIndexNumerator
; System.Photo.ExposureProgram
; System.Photo.ExposureProgramText
; System.Photo.ExposureTime
; System.Photo.ExposureTimeDenominator
; System.Photo.ExposureTimeNumerator
; System.Photo.Flash
; System.Photo.FlashEnergy
; System.Photo.FlashEnergyDenominator
; System.Photo.FlashEnergyNumerator
; System.Photo.FlashManufacturer
; System.Photo.FlashModel
; System.Photo.FlashText
; System.Photo.FNumber
; System.Photo.FNumberDenominator
; System.Photo.FNumberNumerator
; System.Photo.FocalLength
; System.Photo.FocalLengthDenominator
; System.Photo.FocalLengthInFilm
; System.Photo.FocalLengthNumerator
; System.Photo.FocalPlaneXResolution
; System.Photo.FocalPlaneXResolutionDenominator
; System.Photo.FocalPlaneXResolutionNumerator
; System.Photo.FocalPlaneYResolution
; System.Photo.FocalPlaneYResolutionDenominator
; System.Photo.FocalPlaneYResolutionNumerator
; System.Photo.GainControl
; System.Photo.GainControlDenominator
; System.Photo.GainControlNumerator
; System.Photo.GainControlText
; System.Photo.ISOSpeed
; System.Photo.LensManufacturer
; System.Photo.LensModel
; System.Photo.LightSource
; System.Photo.MakerNote
; System.Photo.MakerNoteOffset
; System.Photo.MaxAperture
; System.Photo.MaxApertureDenominator
; System.Photo.MaxApertureNumerator
; System.Photo.MeteringMode
; System.Photo.MeteringModeText
; System.Photo.Orientation
; System.Photo.OrientationText
; System.Photo.PeopleNames
; System.Photo.PhotometricInterpretation
; System.Photo.PhotometricInterpretationText
; System.Photo.ProgramMode
; System.Photo.ProgramModeText
; System.Photo.RelatedSoundFile
; System.Photo.Saturation
; System.Photo.SaturationText
; System.Photo.Sharpness
; System.Photo.SharpnessText
; System.Photo.ShutterSpeed
; System.Photo.ShutterSpeedDenominator
; System.Photo.ShutterSpeedNumerator
; System.Photo.SubjectDistance
; System.Photo.SubjectDistanceDenominator
; System.Photo.SubjectDistanceNumerator
; System.Photo.TagViewAggregate
; System.Photo.TranscodedForSync
; System.Photo.WhiteBalance
; System.Photo.WhiteBalanceText
; System.PropGroup.Advanced
; System.PropGroup.Audio
; System.PropGroup.Calendar
; System.PropGroup.Camera
; System.PropGroup.Contact
; System.PropGroup.Content
; System.PropGroup.Description
; System.PropGroup.FileSystem
; System.PropGroup.General
; System.PropGroup.GPS
; System.PropGroup.Image
; System.PropGroup.Media
; System.PropGroup.MediaAdvanced
; System.PropGroup.Message
; System.PropGroup.Music
; System.PropGroup.Origin
; System.PropGroup.PhotoAdvanced
; System.PropGroup.RecordedTV
; System.PropGroup.Video
; System.InfoTipText
; System.PropList.ConflictPrompt
; System.PropList.ContentViewModeForBrowse
; System.PropList.ContentViewModeForSearch
; System.PropList.ExtendedTileInfo
; System.PropList.FileOperationPrompt
; System.PropList.FullDetails
; System.PropList.InfoTip
; System.PropList.NonPersonal
; System.PropList.PreviewDetails
; System.PropList.PreviewTitle
; System.PropList.QuickTip
; System.PropList.TileInfo
; System.PropList.XPDetailsPanel
; System.RecordedTV.ChannelNumber
; System.RecordedTV.Credits
; System.RecordedTV.DateContentExpires
; System.RecordedTV.EpisodeName
; System.RecordedTV.IsATSCContent
; System.RecordedTV.IsClosedCaptioningAvailable
; System.RecordedTV.IsDTVContent
; System.RecordedTV.IsHDContent
; System.RecordedTV.IsRepeatBroadcast
; System.RecordedTV.IsSAP
; System.RecordedTV.NetworkAffiliation
; System.RecordedTV.OriginalBroadcastDate
; System.RecordedTV.ProgramDescription
; System.RecordedTV.RecordingTime
; System.RecordedTV.StationCallSign
; System.RecordedTV.StationName
; System.Security.AllowedEnterpriseDataProtectionIdentities
; System.Security.EncryptionOwners
; System.Security.EncryptionOwnersDisplay
; System.Search.AutoSummary
; System.Search.ContainerHash
; System.Search.Contents
; System.Search.EntryID
; System.Search.ExtendedProperties
; System.Search.GatherTime
; System.Search.HitCount
; System.Search.IsClosedDirectory
; System.Search.IsFullyContained
; System.Search.QueryFocusedSummary
; System.Search.QueryFocusedSummaryWithFallback
; System.Search.QueryPropertyHits
; System.Search.Rank
; System.Search.Store
; System.Search.UrlToIndex
; System.Search.UrlToIndexWithModificationTime
; System.DescriptionID
; System.InternalName
; System.LibraryLocationsCount
; System.Link.TargetSFGAOFlagsStrings
; System.Link.TargetUrl
; System.NamespaceCLSID
; System.Shell.SFGAOFlagsStrings
; System.StatusBarSelectedItemCount
; System.StatusBarViewItemCount
; System.AppUserModel.ExcludeFromShowInNewInstall
; System.AppUserModel.ID
; System.AppUserModel.IsDestListSeparator
; System.AppUserModel.IsDualMode
; System.AppUserModel.PreventPinning
; System.AppUserModel.RelaunchCommand
; System.AppUserModel.RelaunchDisplayNameResource
; System.AppUserModel.RelaunchIconResource
; System.AppUserModel.StartPinOption
; System.AppUserModel.ToastActivatorCLSID
; System.EdgeGesture.DisableTouchWhenFullscreen
; System.Software.DateLastUsed
; System.Software.ProductName
; System.Supplemental.AlbumID
; System.Supplemental.ResourceId
; System.Sync.Comments
; System.Sync.ConflictDescription
; System.Sync.ConflictFirstLocation
; System.Sync.ConflictSecondLocation
; System.Sync.HandlerCollectionID
; System.Sync.HandlerID
; System.Sync.HandlerName
; System.Sync.HandlerType
; System.Sync.HandlerTypeLabel
; System.Sync.ItemID
; System.Sync.ItemName
; System.Sync.ProgressPercentage
; System.Sync.State
; System.Sync.Status
; System.Task.BillingInformation
; System.Task.CompletionStatus
; System.Task.Owner
; System.Video.Compression
; System.Video.Director
; System.Video.EncodingBitrate
; System.Video.FourCC
; System.Video.FrameHeight
; System.Video.FrameRate
; System.Video.FrameWidth
; System.Video.HorizontalAspectRatio
; System.Video.IsSpherical
; System.Video.IsStereo
; System.Video.Orientation
; System.Video.SampleSize
; System.Video.StreamName
; System.Video.StreamNumber
; System.Video.TotalBitrate
; System.Video.TranscodedForSync
; System.Video.VerticalAspectRatio
; System.Volume.FileSystem
; System.Volume.IsMappedDrive
; System.Volume.IsRoot
; Name
; Size
; Item type
; Date modified
; Date created
; Date accessed
; Attributes
; Offline status
; Offline availability
; Perceived type
; Owner
; Kind
; Date taken
; Contributing artists
; Album
; Year
; Genre
; Conductors
; Tags
; Rating
; Authors
; Title
; Subject
; Categories
; Comments
; Copyright
; #
; Length
; Bit rate
; Protected
; Camera model
; Dimensions
; Camera maker
; Company
; File description
; Program name
; Duration
; Is online
; Is recurring
; Location
; Optional attendee addresses
; Optional attendees
; Organizer address
; Organizer name
; Reminder time
; Required attendee addresses
; Required attendees
; Resources
; Meeting status
; Free/busy status
; Total size
; Account name
; Task status
; Computer
; Anniversary
; Assistant's name
; Assistant's phone
; Birthday
; Business address
; Business city
; Business country/region
; Business P.O. box
; Business postal code
; Business state or province
; Business street
; Business fax
; Business home page
; Business phone
; Callback number
; Car phone
; Children
; Company main phone
; Department
; E-mail address
; E-mail2
; E-mail3
; E-mail list
; E-mail display name
; File as
; First name
; Full name
; Gender
; Given name
; Hobbies
; Home address
; Home city
; Home country/region
; Home P.O. box
; Home postal code
; Home state or province
; Home street
; Home fax
; Home phone
; IM addresses
; Initials
; Job title
; Label
; Last name
; Mailing address
; Middle name
; Cell phone
; Nickname
; Office location
; Other address
; Other city
; Other country/region
; Other P.O. box
; Other postal code
; Other state or province
; Other street
; Pager
; Personal title
; City
; Country/region
; P.O. box
; Postal code
; State or province
; Street
; Primary e-mail
; Primary phone
; Profession
; Spouse/Partner
; Suffix
; TTY/TTD phone
; Telex
; Webpage
; Content status
; Content type
; Date acquired
; Date archived
; Date completed
; Device category
; Connected
; Discovery method
; Friendly name
; Local computer
; Manufacturer
; Model
; Paired
; Classification
; Status
; Client ID
; Contributors
; Content created
; Last printed
; Date last saved
; Division
; Document ID
; Pages
; Slides
; Total editing time
; Word count
; Due date
; End date
; File count
; Filename
; File version
; Flag color
; Flag status
; Space free
; Bit depth
; Horizontal resolution
; Width
; Vertical resolution
; Height
; Importance
; Is attachment
; Is deleted
; Encryption status
; Has flag
; Is completed
; Incomplete
; Read status
; Shared
; Creators
; Date
; Folder name
; Folder path
; Folder
; Participants
; Path
; By location
; Type
; Contact names
; Entry type
; Language
; Date visited
; Description
; Link status
; Link target
; URL
; Media created
; Date released
; Encoded by
; Producers
; Publisher
; Subtitle
; User web URL
; Writers
; Attachments
; Bcc addresses
; Bcc
; Cc addresses
; Cc
; Conversation ID
; Date received
; Date sent
; From addresses
; From
; Has attachments
; Sender address
; Sender name
; Store
; To addresses
; To do title
; To
; Mileage
; Album artist
; Album ID
; Beats-per-minute
; Composers
; Initial key
; Part of a compilation
; Mood
; Part of set
; Period
; Color
; Parental rating
; Parental rating reason
; Space used
; EXIF version
; Event
; Exposure bias
; Exposure program
; Exposure time
; F-stop
; Flash mode
; Focal length
; 35mm focal length
; ISO speed
; Lens maker
; Lens model
; Light source
; Max aperture
; Metering mode
; Orientation
; People
; Program mode
; Saturation
; Subject distance
; White balance
; Priority
; Project
; Channel number
; Episode name
; Closed captioning
; Rerun
; SAP
; Broadcast date
; Program description
; Recording time
; Station call sign
; Station name
; Summary
; Snippets
; Auto summary
; Search ranking
; Sensitivity
; Shared with
; Sharing status
; Product name
; Product version
; Support link
; Source
; Start date
; Billing information
; Complete
; Task owner
; Total file size
; Legal trademarks
; Video compression
; Directors
; Data rate
; Frame height
; Frame rate
; Frame width
; Total bitrate