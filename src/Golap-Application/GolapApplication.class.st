Class {
	#name : 'GolapApplication',
	#superclass : 'ClapApplication',
	#classInstVars : [
		'sessionState'
	],
	#category : 'Golap-Application',
	#package : 'Golap-Application'
}

{ #category : 'deployment' }
GolapApplication class >> deploy [

	<script>
	GolapMenubar reset.
	GolapNamedProject flushCurrent.
	GolapNetworkClientPresenter flushCurrent.
	MCRepositoryGroup allSubInstancesDo: [ :group | group repositories do: [ :repo | group removeRepository: repo ] ].
	IceRepository registry removeAll.
	IceCredentialStore current in: [ :store | store allCredentials do: [ :each | each removeFrom: store ] ].
	self currentWorld closeAllWindowsDiscardingChanges.
	Deprecation
		raiseWarning: false;
		showWarning: false.
	NoSourcesManager beCurrent.
	"NoPharoFilesOpener install."
	"FFICompilerPlugin install."
	Stdio useNullStreams.
	MCCacheRepository uniqueInstance disable.
	EpMonitor reset.
	SessionManager default registerSystemClassNamed: #FreeTypeFileInfo.
	Golap allInstancesDo: [ :g | g becomeForward: Object new ].
	PasteUpMorph shouldShowWorldMenu: false.
	5 timesRepeat: [ Smalltalk garbageCollect ]
]

{ #category : 'commandline' }
GolapApplication class >> gOLAP [

	<commandline>
	^ (ClapCommandSpec id: #gOLAP)
		  description: 'Graph-based OLAP client';
		  commandClass: self;
		  addHelp;
		  yourself
]

{ #category : 'class initialization' }
GolapApplication class >> initialize [

	SessionManager default registerUserClassNamed: self name
]

{ #category : 'sessions' }
GolapApplication class >> resume [

	self sessionState: #resuming do: [
			[
				self sessionFile readStreamDo: [ :stream |
						(GolapJSON fromStream: stream) ifNotNil: [ :json |
								json
									at: 'session' ifPresent: [ :session | GolapPhantasmicProject fromJSON: session ];
									at: 'default-font' ifPresent: [ :font | Golap defaultFontFromJSON: font ];
									at: 'name-delimiter' ifPresent: [ :string | Golap nameEndOfLineDelimiter: string ];
									at: 'colors' ifPresent: [ :colors | GolapColorPreferences fromJSON: colors ] ] ] ]
				on: Exception
				do: [ :ex |  ] ]
]

{ #category : 'sessions' }
GolapApplication class >> sessionFile [

	^ Golap golapDirectory / '.golap'
]

{ #category : 'sessions' }
GolapApplication class >> sessionState: aSymbol do: aBlock [

	sessionState ifNil: [
			sessionState := aSymbol.
			aBlock ensure: [ sessionState := nil ] ]
]

{ #category : 'sessions' }
GolapApplication class >> sessionTemporaryFile [

	^ Golap golapDirectory / (String streamContents: [ :stream |
			   | now |
			   stream nextPutAll: '.golap-'.
			   now := DateAndTime now.
			   now year
				   printOn: stream
				   base: 10
				   length: 4
				   padded: true.
			   now month
				   printOn: stream
				   base: 10
				   length: 2
				   padded: true.
			   now day
				   printOn: stream
				   base: 10
				   length: 2
				   padded: true.
			   stream nextPut: $-.
			   now hour
				   printOn: stream
				   base: 10
				   length: 2
				   padded: true.
			   now minute
				   printOn: stream
				   base: 10
				   length: 2
				   padded: true.
			   now second
				   printOn: stream
				   base: 10
				   length: 2
				   padded: true.
			   stream nextPut: $-.
			   now nanoSecond
				   printOn: stream
				   base: 10
				   length: 9
				   padded: true ])
]

{ #category : 'sessions' }
GolapApplication class >> shutDown: aBoolean [

	aBoolean ifTrue: [ self suspend ]
]

{ #category : 'sessions' }
GolapApplication class >> startUp: aBoolean [

	aBoolean ifTrue: [
		Smalltalk session addDeferredStartupAction: [ self resume ] ]
]

{ #category : 'sessions' }
GolapApplication class >> suspend [

	self sessionState: #suspending do: [
			[
				| json |
				json := Dictionary new.
				GolapPhantasmicProject asJSON ifNotNil: [ :project | json at: 'session' put: project ].
				GolapColorPreferences asJSON ifNotNil: [ :colors | json at: 'colors' put: colors ].
				Golap defaultFontAsJSON ifNotNil: [ :font | json at: 'default-font' put: font ].
				self sessionTemporaryFile
					ensureDelete;
					writeStreamDo: [ :stream | (NeoJSONWriter on: stream) nextPut: json ];
					renameTo: (self sessionFile
							 ensureDelete;
							 basename) ]
				on: Exception
				do: [ :ex |  ] ]
]

{ #category : 'execution' }
GolapApplication >> execute [

	self
		installMenu;
		installIcon;
		installQuitSession
]

{ #category : 'installing' }
GolapApplication >> installIcon [

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
GolapApplication >> installMenu [

	GolapMenubar reset.
	OSWindowDriver current startUp: true.
	"OSPlatform current isMacOSX ifTrue: [
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
			main setAsMainMenu.
			MenubarMorph showMenubar: false]"
]

{ #category : 'installing' }
GolapApplication >> installQuitSession [

	Smalltalk
		at: #WorldState
		ifPresent: [ :class |
		class class compile: 'quitSession GolapNamedProject quit' ]
]
