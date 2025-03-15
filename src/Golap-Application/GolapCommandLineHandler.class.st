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
GolapCommandLineHandler class >> generate [

	<script: 'GolapCommandLineHandler generate'>
	PhleeterOnOSX new
		properties: {
				(#AppName -> 'gOLAP').
				(#InfoString -> 'A client for gOLAP server').
				(#BundleIdentifier -> 'com.github.tomooda.gOLAP').
				(#ShortVersion -> '1.0.0').
				(#DisplayName -> 'gOLAP').
				(#IconSetFile
				 ->
					 ((IceRepository repositoryNamed: 'gOLAP') location / 'resources'
					  / 'gOLAP.icns')).
				(#DiskIconSetFile
				 ->
					 ((IceRepository repositoryNamed: 'gOLAP') location / 'resources'
					  / 'gOLAP-disk.icns')).
				(#DeployPharoExpression -> 'Golap deploy').
				(#CommandLineHandler -> self commandName).
				(#CompanyName -> 'gOLAP project') } asDictionary;
		targetPlatforms: #( 'Windows-x86_64' );
		outputDirectory: FileLocator home / 'src' / 'gOLAP' / 'build';
		addExternalDirectory:
			(IceRepository repositoryNamed: 'gOLAP') location / 'resources'
			/ 'Fonts';
		addExternalFile:
			(IceRepository repositoryNamed: 'gOLAP') location / 'resources'
			/ 'gOLAP-logo.png'
		destination: 'pharo-local/gOLAP/gOLAP-logo.png';
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
