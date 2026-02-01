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
		targetPlatforms:
			#( 'Darwin-arm64' 'Darwin-x86_64' 'Windows-x86_64' );
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
		installIcon;
		installQuitSession
]

{ #category : 'installing' }
GolapCommandLineHandler >> installIcon [

	| icon r logo |
	icon := Form extent: 128 @ 128 depth: 32.
	r := 32.
	icon getCanvas
		fillColor: Color transparent;
		fillRectangle: (r @ 0 corner: 128 - r @ 128) color: Color white;
		fillRectangle: (0 @ r corner: 128 @ (128 - r)) color: Color white;
		fillOval: (0 @ 0 extent: r @ r * 2) color: Color white;
		fillOval: (128 - r - r @ 0 extent: r @ r * 2) color: Color white;
		fillOval: (0 @ (128 - r - r) extent: r @ r * 2) color: Color white;
		fillOval: (128 - r - r @ (128 - r - r) extent: r @ r * 2)
		color: Color white.
	logo := (Form fromFileNamed:
		         FileLocator localDirectory / 'gOLAP' / 'gOLAP-logo.png')
		        scaledToSize: 128 @ 128.
	icon getCanvas
		translucentImage: logo
		at: icon extent - logo extent / 2.0.
	self currentWorld worldState worldRenderer osWindow icon: icon
]

{ #category : 'installing' }
GolapCommandLineHandler >> installMenu [

	OSWindowDriver current startUp: true.
	OSPlatform current isMacOSX ifTrue: [
			| main |
			main := CocoaMenu new.
			main
				title: 'MainMenu';
				addSubmenu: 'ファイル' with: [ :m |
						m
							addItemWithTitle: '設定...' action: [ Golap showSettingBrowser ];
							addItemWithTitle: 'サーバクエリ...'
							action: [ GolapNetworkClientPresenter open ];
							addItemWithTitle: 'CSVファイルを開く...'
							action: [ GolapCSVLauncher open ];
							addItemWithTitle: '終了'
							action: [ Smalltalk snapshot: false andQuit: true ]
							shortcut: 'q' ];
				addSubmenu: 'ヘルプ' with: [ :m |
					m
						addItemWithTitle: 'ヘルプを表示'
						action: [ self inform: 'Help' ]
						shortcut: '' ].
			main setAsMainMenu ]
]

{ #category : 'installing' }
GolapCommandLineHandler >> installQuitSession [

	Smalltalk
		at: #WorldState
		ifPresent: [ :class |
		class class compile: 'quitSession GolapProject quit' ]
]
