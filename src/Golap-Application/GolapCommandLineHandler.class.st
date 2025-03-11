Class {
	#name : 'GolapCommandLineHandler',
	#superclass : 'CommandLineHandler',
	#category : 'Golap-Application',
	#package : 'Golap-Application'
}

{ #category : 'accessing' }
GolapCommandLineHandler class >> commandName [

	^ 'gOLAP'
]

{ #category : 'utilities' }
GolapCommandLineHandler class >> generateMacOS [

	<script: 'GolapCommandLineHandler generateMacOS'>
	GolapAppGeneratorOSXGenerator new
		properties: {
				(#AppName -> 'gOLAP').
				(#InfoString -> 'A client for gOLAP server').
				(#BundleIdentifier -> 'com.github.tomooda.gOLAP').
				(#ShortVersion -> '0.9.0').
				(#DisplayName -> 'gOLAP').
				(#IconSetFile
				 ->
					 ((IceRepository repositoryNamed: 'gOLAP') location / 'resources'
					  / 'gOLAP.icns')).
				(#CommandLineHandler -> self commandName).
				(#CompanyName -> 'gOLAP project') } asDictionary;
		outputDirectory: FileLocator home / 'src' / 'gOLAP' / 'mac';
		addExternalDirectory:
			(IceRepository repositoryNamed: 'gOLAP') location / 'resources'
			/ 'Fonts';
		addExternalFile:
			(IceRepository repositoryNamed: 'gOLAP') location / 'resources'
			/ 'gOLAP-logo.png'
		destination: 'pharo-local/gOLAP/gOLAP-logo.png';
		generate
]

{ #category : 'utilities' }
GolapCommandLineHandler class >> generateWindows [

	<script>
	AppGeneratorWindowsGenerator new
		properties: {
				(#AppName -> 'gOLAP').
				(#InfoString -> 'A client for gOLAP server').
				(#BundleIdentifier -> 'com.github.tomooda.gOLAP').
				(#ShortVersion -> '0.9.0').
				(#DisplayName -> 'gOLAP').
				(#CommandLineHandler -> self commandName).
				(#IconFile
				 ->
					 ((IceRepository repositoryNamed: 'gOLAP') location / 'resources'
					  / 'gOLAP.ico')).
				(#CompanyName -> 'gOLAP project').
				(#LegalCopyright
				 -> 'Copyright \251 https://github.com/tomooda/gOLAP/ 2020\0') }
				asDictionary;
		outputDirectory: FileLocator home / 'src' / 'gOLAP' / 'windows';
		generate
]

{ #category : 'activation' }
GolapCommandLineHandler >> activate [

	self
		installMenu;
		installQuitSession
]

{ #category : 'installing' }
GolapCommandLineHandler >> installMenu [

	OSWindowDriver current startUp: true.
	OSPlatform current isMacOSX ifTrue: [
		| main |
		main := CocoaMenu new.
		main
			title: 'MainMenu';
			addSubmenu: 'File' with: [ :m |
				m
					addItemWithTitle: 'Settings...'
					action: [ Golap showSettingBrowser ];
					addItemWithTitle: 'Open Server...' action: [ Golap openClient ];
					addItemWithTitle: 'Open CSV files...'
					action: [ GolapCSVLauncher open ];
					addItemWithTitle: 'Quit'
					action: [ Smalltalk snapshot: false andQuit: true ]
					shortcut: 'q' ];
			addSubmenu: 'Help' with: [ :m |
			m
				addItemWithTitle: 'Show Help'
				action: [ self inform: 'Help' ]
				shortcut: '' ].
		main setAsMainMenu ]
]

{ #category : 'installing' }
GolapCommandLineHandler >> installQuitSession [

	Smalltalk at: #WorldState ifPresent: [ :class |
		class class compile:
			'quitSession Smalltalk snapshot: false andQuit: true' ]
]
