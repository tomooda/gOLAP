Class {
	#name : #Golap,
	#superclass : #SpPresenter,
	#instVars : [
		'model',
		'url',
		'query',
		'overviewRenderer',
		'elaborationRenderer',
		'visibleEdges',
		'globalImagePane',
		'pins',
		'selections',
		'overridesYWithFrequencyCheckbox',
		'layoutButton',
		'zoomInButton',
		'zoomOutButton',
		'resetZoomButton',
		'globalMapPane',
		'vertexList',
		'font',
		'itemView',
		'baseList',
		'dimensions',
		'merges',
		'frontList',
		'selectedEdges',
		'queryViewTree',
		'itemsAppearancePresenter',
		'saveAsButton',
		'elaborationRendererButton',
		'overviewRendererButton',
		'rendererSelector',
		'authenticateBlock',
		'edgesAppearancePresenter',
		'colorsAppearancePresenter',
		'lastSelectedMarkerItem',
		'saveAsPngButton',
		'appearanceNotebook',
		'itemList',
		'itemNotebook',
		'snapshotDirectory',
		'snapshotEnabled',
		'resentQueryButton',
		'lastZoomTimestamp',
		'saveAsSvgButton',
		'saveSnapshotButton',
		'photoImageRetrievingProcess',
		'retrievalProcessCount',
		'drawingSemaphore'
	],
	#classVars : [
		'NameEndOfLineDelimiter'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #utilities }
Golap class >> defaultFont [
	^ StandardFonts defaultFont
]

{ #category : #utilities }
Golap class >> defaultFont: aFont [
	^ StandardFonts defaultFont: aFont
]

{ #category : #layout }
Golap class >> defaultLayout [

	<spec>
	^ SpBoxLayout newHorizontal
		  add: (SpBoxLayout newVertical
				   add: #globalMapPane height: 200;
				   add: (SpBoxLayout newHorizontal
						    add: #zoomInButton width: 110;
						    add: #resetZoomButton width: 80;
						    add: #zoomOutButton width: 110)
				   height: self buttonHeight;
				   add: (SpBoxLayout newHorizontal
						    add: #frontList width: 150;
						    add: #baseList)
				   height: self buttonHeight;
				   add: #appearanceNotebook height: 300;
				   add: (SpBoxLayout newHorizontal
						    add: #overviewRendererButton;
						    add: #elaborationRendererButton)
				   height: self buttonHeight;
				   add: (SpBoxLayout newHorizontal
						    add: #layoutButton expand: true;
						    add: #overridesYWithFrequencyCheckbox width: 100)
				   height: self buttonHeight)
		  width: 350;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 0.75;
				   add: #globalImagePane;
				   add: (SpBoxLayout newVertical
						    add: #saveSnapshotButton height: self buttonHeight;
						    add: #saveAsSvgButton height: self buttonHeight;
						    add: #saveAsPngButton height: self buttonHeight;
						    add: #resentQueryButton height: self buttonHeight;
						    add: #queryViewTree height: 200;
						    add: #itemNotebook))
]

{ #category : #utilities }
Golap class >> deploy [
	<script>
	GolapNetworkClientPresenter flushCurrent.
	Smalltalk cleanUp: true except: {} confirming: false.
	MCRepositoryGroup
		allSubInstancesDo:
			[ :group | group repositories do: [ :repo | group removeRepository: repo ] ].
	IceRepository registry removeAll.
	IceCredentialStore current
		in:
			[ :store | store allCredentials do: [ :each | each removeFrom: store ] ].
	World closeAllWindowsDiscardingChanges.
	Deprecation
		raiseWarning: false;
		showWarning: false.
	NoChangesLog install.
	"NoPharoFilesOpener install."
	FFICompilerPlugin install.
	Stdio useNullStreams.
	MCCacheRepository uniqueInstance disable.
	EpMonitor reset.
	5 timesRepeat: [ Smalltalk garbageCollect ]
	"PharoCommandLineHandler forcePreferencesOmission: true"
]

{ #category : #settings }
Golap class >> gOLAPSettingsOn: aBuilder [
	<systemsettings>
	(aBuilder group: #gOLAP)
		label: 'gOLAP';
		with: [ (aBuilder setting: #defaultFont)
				order: 1;
				description: 'The default text font';
				label: 'Font'.
			(aBuilder setting: #nameEndOfLineDelimiter)
				order: 2;
				description: 'The end of line delimiter for item names';
				label: 'End-of-Line for item name' ]
]

{ #category : #menus }
Golap class >> golapMenuOn: aBuilder [

	<worldMenu>
	(aBuilder item: #Golap)
		label: 'gOLAP';
		order: 1;
		with: [ 
			(aBuilder item: #'Snapshot Browser')
				parent: 'Golap';
				target: GolapSnapshotBrowser ;
				selector: #open;
				help: 'Open a snapshot launcher';
				withSeparatorAfter.
			(aBuilder item: #'Open File...')
				parent: 'Golap';
				target: self;
				selector: #openFile;
				help: 'Open a CSV file with dimensions';
				withSeparatorAfter.
			(aBuilder item: #'Open URL...')
				parent: 'Golap';
				target: self;
				selector: #openNewClient;
				help:
					'Open a CSV file with dimensions from a server with a blank query'.
			(aBuilder item: #'Open URL again...')
				parent: 'Golap';
				target: self;
				selector: #openClient;
				help:
					'Open a CSV file with dimensions from a server with the previous query';
				withSeparatorAfter.
			(aBuilder item: #'Settings...')
				parent: 'Golap';
				target: self;
				selector: #showSettingBrowser;
				help: 'Open a settings dialog for gOLAP' ]
]

{ #category : #accessing }
Golap class >> nameEndOfLineDelimiter [
	^ NameEndOfLineDelimiter ifNil: [ '||' ]
]

{ #category : #accessing }
Golap class >> nameEndOfLineDelimiter: aString [
	NameEndOfLineDelimiter := aString
]

{ #category : #utilities }
Golap class >> open [

	<script: 'GolapOverview open'>
	| overview |
	overview := Golap new.
	overview open maximize.
	^ overview
		  updateGlobalImageAfter: [ 
			  overview
				  model: nil;
				  minimalSpanningTree ]
		  layout: true;
		  yourself
]

{ #category : #examples }
Golap class >> openClient [

	<script: 'GolapOverview openClient'>
	| overview |
	overview := Golap new.
	overview open maximize.
	GolapNetworkClientPresenter
		openDialogIfAccepted: [ :client | 
			[ 
			overview
				authenticateBlock: client authenticateBlock;
				query: (NeoJSONReader fromString: client query);
				url: client url;
				imageRepositoryUrl: client imageUrl;
				itemFieldQuerySpec: client itemFieldQuerySpec;
				itemViewUrl: client url ]
				on: Error
				do: [ :ex | 
					UIManager default alert:
						'Can''t open the given URL: ' , client url asString ].
			overview snapshotData: client readStream do: [ :readStream | 
				readStream ifNil: [ overview delete ] ifNotNil: [ 
					readStream isString
						ifTrue: [ 
							UIManager default alert: readStream.
							overview delete ]
						ifFalse: [ 
							Cursor wait showWhile: [ 
								UIManager default informUserDuring: [ :bar | 
									bar
										min: 0;
										max: readStream size.
									overview
										updateGlobalImageAfter: [ 
											[ 
											bar value: readStream position.
											readStream atEnd ] whileFalse: [ 
												overview readDimensionFrom: readStream ].
											bar label: 'updating dimensions'.
											overview updateDimensions.
											bar label: 'updating models'.
											overview updateModel.
											overview numFriends: 5.
											overview jaccardMode.
											bar label: 'updating graph' ]
										layout: true.
									overview updateGlobalImageAfter: [  ] layout: true ] ] ] ] ] ]
		ifCanceled: [ overview delete ]
]

{ #category : #examples }
Golap class >> openFile [

	<script: 'GolapOverview openFile'>
	| overview |
	overview := Golap new.
	overview open maximize.
	(UIManager default
		 chooseExistingFileReference: 'Select a coocurrence file'
		 extensions: #( 'csv' )
		 path: GolapModel coocurrenceDataDirectory) in: [ :ref | 
		(ref notNil and: [ ref isFile ])
			ifTrue: [ 
				overview snapshotData: ref readStream do: [ :readStream | 
					readStream isString
						ifTrue: [ 
							UIManager default alert: readStream.
							overview delete ]
						ifFalse: [ 
							Cursor wait showWhile: [ 
								UIManager default informUserDuring: [ :bar | 
									bar
										min: 0;
										max: readStream size.
									overview
										updateGlobalImageAfter: [ 
											[ 
											bar value: readStream position.
											readStream atEnd ] whileFalse: [ 
												overview readDimensionFrom: readStream ].
											bar label: 'updating dimensions'.
											overview updateDimensions.
											bar label: 'updating models'.
											overview updateModel.
											overview numFriends: 5.
											overview jaccardMode.
											bar label: 'updating graph' ]
										layout: true ] ] ] ] ]
			ifFalse: [ overview delete ] ].
	^ overview
]

{ #category : #examples }
Golap class >> openNewClient [
	<script: 'GolapDimensionsOverview openNewClient'>
	GolapNetworkClientPresenter flushCurrent.
	^ self openClient
]

{ #category : #menus }
Golap class >> showSettingBrowser [
	<script>
	SettingBrowser new
		changePackageSet:
			{(RPackageOrganizer default packageNamed: #'Network-Kernel').
			(RPackageOrganizer default packageNamed: #'Golap-UI')};
		open
]

{ #category : #'accessing-dimensions' }
Golap >> addDimension: aGolapOverviewModel named: aString [
	dimensions at: aString put: aGolapOverviewModel.
	frontList items: dimensions keys.
	baseList
		items:
			(dimensions keys
				collect: [ :base | 
					frontList selectedItem = base
						ifTrue: [ String new ]
						ifFalse: [ base ] ]).
	^ aGolapOverviewModel
]

{ #category : #merging }
Golap >> applyMergesToModel: aGolapModel [
	| positions |
	positions := Dictionary
		new: (model ifNil: [ 256 ] ifNotNil: [ model vertices size * 3 // 2 ]).
	model
		ifNotNil: [ model
				verticesDo: [ :v | v asPoint ifNotNil: [ :p | positions at: v data put: p ] ] ].
	aGolapModel recreateVertices.
	aGolapModel
		verticesDo: [ :v | 
			positions
				at: v data
				ifPresent: [ :p | 
					v
						x: p x;
						y: p y ] ].
	merges
		do: [ :assoc | 
			| oldVertices newVertex |
			oldVertices := assoc value
				collect: [ :id | aGolapModel vertices at: id ifAbsent: [ nil ] ]
				thenSelect: #notNil.
			newVertex := aGolapModel
				mergeVertices:
					(assoc value
						collect: [ :id | aGolapModel vertices at: id ifAbsent: [ nil ] ]
						thenSelect: #notNil)
				named: assoc key.
			newVertex
				x:
					((oldVertices collect: #x thenSelect: #notNil)
						ifEmpty: [ nil ]
						ifNotEmpty: #average);
				y:
					((oldVertices collect: #y thenSelect: #notNil)
						ifEmpty: [ nil ]
						ifNotEmpty: #average) ].
	^ aGolapModel
]

{ #category : #accessing }
Golap >> authenticateBlock [

	^ authenticateBlock ifNil: [ 
		  | username password |
		  username := nil.
		  password := nil.
		  ^ authenticateBlock := [ :auth | 
		                         username ifNil: [ 
			                         username := UIManager default request:
				                                     'username' ].
		                         username ifNotNil: [ 
			                         password ifNil: [ 
				                         password := UIManager default 
					                                     requestPassword: 'password' ].
			                         password
				                         ifNotNil: [ 
				                         auth value: username value: password ]
				                         ifNil: [ username := nil ] ] ] ]
]

{ #category : #accessing }
Golap >> authenticateBlock: aBlock [
	authenticateBlock := aBlock.
	itemView ifNotNil: [ itemView authenticateBlock: aBlock ]
]

{ #category : #operations }
Golap >> averageMode [
	edgesAppearancePresenter averageMode
]

{ #category : #'accessing-renderer' }
Golap >> basicLayout [
	self renderer
		overridesYWithFrequency: overridesYWithFrequencyCheckbox state;
		layout
]

{ #category : #snapshot }
Golap >> basicSnapshotDirectory [

	^ snapshotDirectory
]

{ #category : #'accessing-colors' }
Golap >> colorForEdge: aGolapEdge [
	self selectedBaseDimension
		ifNotNil: [ | frontEdge baseEdge v |
			frontEdge := self selectedFrontDimension
				edgeBetween: aGolapEdge vertex1 data
				and: aGolapEdge vertex2 data
				ifAbsent: [  ].
			baseEdge := self selectedBaseDimension
				edgeBetween: aGolapEdge vertex1 data
				and: aGolapEdge vertex2 data
				ifAbsent: [  ].
			(frontEdge isNil and: [ baseEdge notNil ])
				ifTrue: [ ^ self retreatingColor ].
			(frontEdge notNil and: [ baseEdge isNil ])
				ifTrue: [ ^ self freshColor ].
			v := model valueAtEdge: aGolapEdge.
			v < 0
				ifTrue: [ ^ self decliningColor ].
			v > 0
				ifTrue: [ ^ self growingColor ] ].
	^ self normalColor
]

{ #category : #'accessing-colors' }
Golap >> colorForVertex: aGolapVertex [
	(self includesSelection: aGolapVertex)
		ifTrue: [ ^ self selectionColor ].
	self selectedBaseDimension
		ifNotNil: [ | frontVertex baseVertex |
			frontVertex := self selectedFrontDimension
				ifNotNil: [ :dimension | dimension vertexAt: aGolapVertex data ifAbsent: [  ] ].
			baseVertex := self selectedBaseDimension
				ifNotNil: [ :dimension | dimension vertexAt: aGolapVertex data ifAbsent: [  ] ].
			(frontVertex isNil and: [ baseVertex notNil ])
				ifTrue: [ ^ self retreatingColor ].
			(frontVertex notNil and: [ baseVertex isNil ])
				ifTrue: [ ^ self freshColor ].
			aGolapVertex frequency < 0
				ifTrue: [ ^ self decliningColor ].
			aGolapVertex frequency > 0
				ifTrue: [ ^ self growingColor ] ].
	^ self normalColorFor: aGolapVertex
]

{ #category : #operations }
Golap >> copyAllFromQueryViewTree [
	Clipboard
		clipboardText: (STONJSON toString: queryViewTree roots asDictionary)
]

{ #category : #operations }
Golap >> copyFromQueryViewTree [
	queryViewTree selectedItem
		ifNotNil:
			[ :assoc | Clipboard clipboardText: (STONJSON toString: assoc value) ]
		ifNil: [ Clipboard
				clipboardText: (STONJSON toString: queryViewTree roots asDictionary) ]
]

{ #category : #snapshot }
Golap >> createTemporarySnapshotDirectory [

	^ url ifNotNil: [ 
		  | ref |
		  ref := (self golapDirectory / self temporaryDirectoryName
		          /
			          (url host asString , '--' , DateAndTime now printString
			           , '--'
			           ,
			           ((SharedRandom globalGenerator nextInteger: 1000000) - 1)
				           printString)) ensureCreateDirectory.
		  ref / 'createdTime' writeStreamDo: [ :stream | 
			  | now |
			  now := DateAndTime now.
			  stream nextPutAll:
				  now asDate printString , ' ' , now asTime print24 ].
		  ref ]
]

{ #category : #'accessing-colors' }
Golap >> decliningColor [
	^ colorsAppearancePresenter decliningColor
]

{ #category : #operations }
Golap >> degreeMode [
	edgesAppearancePresenter degreeMode
]

{ #category : #'accessing-dimensions' }
Golap >> dimensionAt: aString [
	^ dimensions at: aString ifAbsent: [ nil ]
]

{ #category : #'accessing-dimensions' }
Golap >> dimensionsDo: aBlock [
	dimensions do: aBlock
]

{ #category : #snapshot }
Golap >> disableSnapshotWhile: aBlock [

	| oldSnapshotEnabled |
	oldSnapshotEnabled := snapshotEnabled.
	snapshotEnabled := false.
	aBlock ensure: [ snapshotEnabled := oldSnapshotEnabled ]
]

{ #category : #operations }
Golap >> dumpToFile [
	UIManager default
		informUserDuring: [ :progress | 
			(UIManager default
				chooseForSaveFileReference: 'Save gOLAP data'
				extensions: #('csv')
				path: GolapModel coocurrenceDataDirectory)
				ifNotNil: [ :ref | 
					ref
						writeStreamDo:
							[ :writeStream | self writeCSVOn: writeStream progressBlock: [ :v | progress value: v ] ] ] ]
]

{ #category : #accessing }
Golap >> edgeScale [
	^ edgesAppearancePresenter edgeScale
]

{ #category : #accessing }
Golap >> edgeScale: aNumber [
	edgesAppearancePresenter edgeScale: aNumber
]

{ #category : #'accessing-renderer' }
Golap >> elaborationRenderer [
	^ elaborationRenderer
		ifNil: [ elaborationRenderer := GolapElaborationRenderer on: self ]
]

{ #category : #'operations-photoimages' }
Golap >> ensurePhotoimageRetrievingProcess [

	(photoImageRetrievingProcess isNil or: [ 
		 photoImageRetrievingProcess isTerminating ]) ifTrue: [ 
		self startPhotoimageRetrievingProcess ]
]

{ #category : #private }
Golap >> flushVisibleEdges [
	visibleEdges := nil
]

{ #category : #accessing }
Golap >> font [
	^ font ifNil: [ font := TextStyle defaultFont ]
]

{ #category : #accessing }
Golap >> font: aFont [
	self updateGlobalImageAfter: [ font := aFont ]
]

{ #category : #operations }
Golap >> freqMode [
	edgesAppearancePresenter freqMode
]

{ #category : #operations }
Golap >> frequencyMode [
	edgesAppearancePresenter frequencyMode
]

{ #category : #'accessing-colors' }
Golap >> freshColor [
	^ colorsAppearancePresenter freshColor
]

{ #category : #accessing }
Golap >> friendsEdges [
	| num |
	model ifNil: [ ^ Array new ].
	num := edgesAppearancePresenter numFriends.
	^ model friendsEdges: num
]

{ #category : #menu }
Golap >> globalImageMenu: aGolapVertex [

	| menu |
	menu := self newMenu.
	menu addGroup: [ :group | 
		aGolapVertex ifNotNil: [ 
			(self includesSelection: aGolapVertex)
				ifTrue: [ 
					group addItem: [ :item | 
						item
							name: 'Unselect';
							action: [ self toggleSelection: aGolapVertex ] ] ]
				ifFalse: [ 
					group addItem: [ :item | 
						item
							name: 'Select';
							action: [ self toggleSelection: aGolapVertex ] ] ] ].
		self selections ifNotEmpty: [ 
			group addItem: [ :item | 
				item
					name: 'Unselect all';
					action: [ self unselectAll ] ] ] ].
	aGolapVertex ifNotNil: [ 
		menu
			addGroup: [ :group | 
				(itemList markMenu: aGolapVertex) ifNotNil: [ :submenu | 
						group addItem: [ :item | 
								item
									name: 'Mark';
									subMenu: submenu ] ].
				(itemList unmarkMenu: aGolapVertex) ifNotNil: [ :submenu | 
					group addItem: [ :item | 
						item
							name: 'Unmark';
							subMenu: submenu ] ].
				self selections ifNotEmpty: [ 
					group
						addItem: [ :item | 
							item
								name: 'Mark selections';
								subMenu: itemList markSelectionsMenu ];
						addItem: [ :item | 
							item
								name: 'Unmark selections';
								subMenu: itemList unmarkSelectionsMenu ] ] ];
			addGroup: [ :group | 
				(self includesPin: aGolapVertex)
					ifTrue: [ 
						group addItem: [ :item | 
							item
								name: 'Unpin';
								action: [ self togglePin: aGolapVertex ] ] ]
					ifFalse: [ 
						group addItem: [ :item | 
							item
								name: 'Pin';
								action: [ self togglePin: aGolapVertex ] ] ] ];
			addGroup: [ :group | 
				group addItem: [ :item | 
					item
						name: 'Show info';
						action: [ itemView vertex: aGolapVertex ] ] ] ].
	menu addGroup: [ :group | 
		group addItem: [ :item | 
			item
				name: 'merge';
				subMenu: self mergeMenu ].
		merges ifNotEmpty: [ 
			group addItem: [ :item | 
				item
					name: 'unmerge';
					subMenu: self unmergeMenu ] ] ].
	menu addGroup: [ :group | 
		group addItem: [ :item | 
			item
				name: 'Inspect';
				action: [ self inspect ] ] ].
	^ menu
]

{ #category : #operations }
Golap >> globalImageMouseClick: anEvent [
	| target |
	anEvent wasHandled: true.
	target := self renderer
		vertexAtPoint: anEvent position - globalImagePane adapter widget position.
	anEvent yellowButtonChanged
		ifTrue: [ ^ (self globalImageMenu: target) openWithSpecAt: anEvent position ].
	target ifNotNil: [ self toggleSelection: target ]
]

{ #category : #operations }
Golap >> globalImageMouseMove: anEvent [

	anEvent anyButtonPressed ifFalse: [ ^ self ].
	anEvent wasHandled: true.
	self updateGlobalImageAfter: [ 
		self renderer moveImageOffset: anEvent endPoint - anEvent startPoint ]
]

{ #category : #operations }
Golap >> globalImageMouseWheel: anEvent [

	anEvent direction = Character arrowUp ifTrue: [ ^ self zoomIn ].
	anEvent direction = Character arrowDown ifTrue: [ ^ self zoomOut ]
]

{ #category : #'accessing-widgets' }
Golap >> globalImagePane [
	^ globalImagePane
]

{ #category : #operations }
Golap >> globalMapMouseClick: anEvent [

	anEvent wasHandled: true
]

{ #category : #operations }
Golap >> globalMapMouseMove: anEvent [

	anEvent anyButtonPressed ifFalse: [ ^ self ].
	anEvent wasHandled: true.
	self updateGlobalImageAfter: [ 
		self renderer moveMapOffset: anEvent startPoint - anEvent endPoint ]
]

{ #category : #'accessing-widgets' }
Golap >> globalMapPane [
	^ globalMapPane
]

{ #category : #'accessing-presets' }
Golap >> golapDirectory [
	^ (FileLocator documents / 'gOLAP') ensureCreateDirectory
]

{ #category : #accessing }
Golap >> graphEdges [
	^ model ifNotNil: [ model graphEdges ] ifNil: [ Array new ]
]

{ #category : #'accessing-colors' }
Golap >> growingColor [
	^ colorsAppearancePresenter growingColor
]

{ #category : #menu }
Golap >> iconForCircleColor: aColor [

	^ itemList iconForCircleColor: aColor
]

{ #category : #private }
Golap >> ifNotActive: aBlock [

	adapter ifNil: [ ^ aBlock value ].
	adapter widget ifNil: [ ^ aBlock value ].
	adapter widget world ifNil: [ ^ aBlock value ]
]

{ #category : #snapshot }
Golap >> ifSnapshotEnabled: aBlock [

	snapshotEnabled = true ifTrue: aBlock
]

{ #category : #accessing }
Golap >> imageRepositoryUrl: aString [
	itemView imageRepositoryUrl: aString
]

{ #category : #'accessing-selection' }
Golap >> includesPin: aGolapVertex [
	^ pins includes: aGolapVertex data
]

{ #category : #'accessing-selection' }
Golap >> includesSelection: aGolapVertex [
	^ selections contains: [ :data | aGolapVertex hasData: data ]
]

{ #category : #initialization }
Golap >> initialize [

	super initialize.
	pins := Set new.
	selections := Set new.
	dimensions := OrderedDictionary new.
	merges := OrderedCollection new.
	rendererSelector := #overviewRenderer.
	snapshotEnabled := true.
	lastZoomTimestamp := DateAndTime now.
	drawingSemaphore := Semaphore forMutualExclusion
]

{ #category : #initialization }
Golap >> initializePresenters [

	globalImagePane := self newImage
		                   autoScale: true;
		                   whenBuiltDo: [ 
			                   globalImagePane adapter widget
				                   on: #mouseMove
				                   send: #globalImageMouseMove:
				                   to: self;
				                   on: #mouseUp
				                   send: #globalImageMouseClick:
				                   to: self;
				                   on: #mouseWheel
				                   send: #globalImageMouseWheel:
				                   to: self ];
		                   bindKeyCombination:
		                   Character arrowUp asKeyCombination
		                   toAction: [ self zoomIn ];
		                   bindKeyCombination:
		                   Character arrowDown asKeyCombination
		                   toAction: [ self zoomOut ];
		                   yourself.
	globalMapPane := self newImage
		                 autoScale: false;
		                 whenBuiltDo: [ 
			                 globalMapPane adapter widget
				                 on: #mouseMove
				                 send: #globalMapMouseMove:
				                 to: self;
				                 on: #mouseUp
				                 send: #globalMapMouseClick:
				                 to: self;
				                 on: #mouseWheel
				                 send: #globalImageMouseWheel:
				                 to: self ];
		                 bindKeyCombination: Character arrowUp
		                 toAction: [ self zoomIn ];
		                 bindKeyCombination: Character arrowDown
		                 toAction: [ self zoomOut ];
		                 yourself.
	zoomInButton := self newButton.
	zoomInButton
		label: '+';
		action: [ self zoomInCenter ].
	zoomOutButton := self newButton.
	zoomOutButton
		label: '-';
		action: [ self zoomOutCenter ].
	resetZoomButton := self newButton
		                   label: 'reset';
		                   action: [ self resetZoom ];
		                   yourself.
	frontList := self newDropList
		             display: [ :string | string asString ];
		             whenSelectedItemChangedDo: [ :front | 
			             baseList
				             items: (dimensions ifNil: [ #(  ) ] ifNotNil: [ 
							              dimensions keys asArray collect: [ :back | 
									              front = back
										              ifTrue: [ String new ]
										              ifFalse: [ back ] ] ]);
				             selectItem: String new ];
		             yourself.
	baseList := self newDropList
		            display: [ :string | string asString ];
		            whenSelectedItemChangedDo: [ self updateModel ];
		            yourself.
	itemsAppearancePresenter := GolapItemsAppearance on: self.
	edgesAppearancePresenter := GolapEdgesAppearance on: self.
	colorsAppearancePresenter := GolapColorsAppearance on: self.
	appearanceNotebook := self newNotebook
		                      addPage: (self newNotebookPage
				                       title: 'グラフ';
				                       presenterProvider: [ 
					                       edgesAppearancePresenter ];
				                       yourself);
		                      addPage: (self newNotebookPage
				                       title: '商品';
				                       presenterProvider: [ 
					                       itemsAppearancePresenter ];
				                       yourself);
		                      addPage: (self newNotebookPage
				                       title: '色';
				                       presenterProvider: [ 
					                       colorsAppearancePresenter ];
				                       yourself);
		                      yourself.

	overviewRendererButton := self newButton
		                          state: true;
		                          label: 'overview';
		                          action: [ self setOverviewRenderer ];
		                          yourself.
	elaborationRendererButton := self newButton
		                             state: false;
		                             label: 'elaboration';
		                             action: [ self setElaborationRenderer ];
		                             yourself.
	layoutButton := self newButton.
	layoutButton
		label: 'layout';
		action: [ self updateGlobalImageAfter: [  ] layout: true ].
	overridesYWithFrequencyCheckbox := self newCheckBox
		                                   label: 'Y=freq';
		                                   labelOnRight;
		                                   state: false;
		                                   whenChangedDo: [ 
			                                   self
				                                   updateGlobalImageAfter: [  ]
				                                   layout: true ].
	saveAsButton := self newButton
		                label: 'save...';
		                action: [ self dumpToFile ];
		                yourself.
	saveAsPngButton := self newButton
		                   label: 'save as PNG...';
		                   action: [ self saveFullImage ];
		                   yourself.
	saveAsSvgButton := self newButton
		                   label: 'save as SVG...';
		                   action: [ self saveAsSVG ];
		                   yourself.
	resentQueryButton := self newButton
		                     label: 'resend query';
		                     action: [ self resendQuery ];
		                     yourself.
	saveSnapshotButton := self newButton
		                      label: 'save snapshot...';
		                      action: [ self saveSnapshot ];
		                      yourself.
	queryViewTree := self newTreeTable
		                 addColumn:
			                 (SpStringTableColumn evaluated: [ :assoc | 
					                  assoc key , ' : '
					                  , (STONJSON toString: assoc value) ]);
		                 children: [ :assoc | 
			                 assoc value isDictionary
				                 ifTrue: [ 
					                 assoc value keys asSortedCollection collect: [ 
							                 :k | k -> (assoc value at: k) ] ]
				                 ifFalse: [ Array new ] ];
		                 contextMenu: [ self queryViewTreeMenu ];
		                 yourself.
	itemList := self newGolapItemList.
	itemView := self newGolapItemView.
	itemNotebook := self newNotebook
		                addPage: (self newNotebookPage
				                 title: '商品リスト';
				                 presenterProvider: [ itemList ];
				                 yourself);
		                addPage: (self newNotebookPage
				                 title: '商品情報';
				                 presenterProvider: [ itemView ];
				                 yourself);
		                yourself.

	self whenBuiltDo: [ :w | 
		| f |
		f := TextStyle defaultFont.
		w widget allMorphsDo: [ :m | "self window
			bindKeyCombination: Character arrowUp asKeyCombination
			toAction: [ self zoomIn ];
			bindKeyCombination: Character arrowDown asKeyCombination
			toAction: [ self zoomOut ]" 
			(m respondsTo: #font:) ifTrue: [ m font: f ] ] ]
]

{ #category : #initialization }
Golap >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self title;
		initialExtent: World extent
]

{ #category : #snapshot }
Golap >> isTemporarySnapshot [

	^ self snapshotDirectory parent basename
	  = self temporaryDirectoryName
]

{ #category : #accessing }
Golap >> itemFieldQuerySpec: aDictionary [
	itemView itemFieldQuerySpec: aDictionary
]

{ #category : #'accessing-widgets' }
Golap >> itemView [
	^ itemView
]

{ #category : #accessing }
Golap >> itemViewUrl: aString [
	itemView serverUrl: aString asString asText
]

{ #category : #operations }
Golap >> jaccardMode [
	edgesAppearancePresenter jaccardMode
]

{ #category : #operations }
Golap >> liftMode [
	edgesAppearancePresenter liftMode
]

{ #category : #'accessing-markers' }
Golap >> markedVertices [

	^ itemList markedVertices
]

{ #category : #'accessing-markers' }
Golap >> markersAndVerticesDo: aBlock [

	itemList markersAndVerticesDo: aBlock
]

{ #category : #operations }
Golap >> maxMode [
	edgesAppearancePresenter maxMode
]

{ #category : #'operations-photoimages' }
Golap >> maxPhotoimageRetrievalProcesses [

	^ 3
]

{ #category : #private }
Golap >> maxScale [
	^ 50.0
]

{ #category : #menu }
Golap >> mergeMenu [

	| menu |
	menu := self newMenu.
	menu addGroup: [ :group | 
		selections size > 1 ifTrue: [ 
			group addItem: [ :item | 
				item
					name: 'selections';
					action: [ self mergeSelectedVertices ] ] ].
		itemList markerDropList listItems do: [ :listItem | 
			| color ids |
			color := listItem key.
			ids := itemList markers at: color ifAbsent: [ #(  ) ].
			ids size > 1 ifTrue: [ 
				group addItem: [ :menuItem | 
					menuItem
						name: '';
						icon: (self iconForCircleColor: color);
						action: [ 
							(self mergeVertices: ids copy) ifNotNil: [ :newId | 
									itemList markerDropList items do: [ :item | 
											item key = color ifTrue: [ item value: item value, ',',newId ] ].
									(itemList markers at: color) add: newId.
									itemList currentMarker: color.
									itemList updateVertexList ] ] ] ] ] ].
	^ menu
]

{ #category : #merging }
Golap >> mergeSelectedVertices [
	^ self selections
		ifNotEmpty: [:vs | (self mergeVertices: (vs collect: #data)) ifNotNil: [ :newId | self select: (model vertexAt: newId) ] ]
		ifEmpty: [ nil ]
]

{ #category : #merging }
Golap >> mergeVertices: aCollectionOfIds [

	aCollectionOfIds size < 2 ifTrue: [ ^ nil ].
	^ model ifNotNil: [ 
		  (UIManager default
			   request: '統合したノード名'
			   initialAnswer: ''
			   title: 'ノードの統合') ifNotNil: [ :nodeName | 
			  (model vertices includesKey: nodeName)
				  ifTrue: [ 
					  UIManager default alert: '名前が重複しています'.
					  nil ]
				  ifFalse: [ 
					  merges add: nodeName -> aCollectionOfIds copy.
					  self updateModel.
					  itemList updateVertexList.
					  nodeName ] ] ]
]

{ #category : #private }
Golap >> minScale [
	^ 0.9
]

{ #category : #operations }
Golap >> minimalSpanningTree [
	edgesAppearancePresenter minimalSpanningTree
]

{ #category : #accessing }
Golap >> model [
	^ model
]

{ #category : #accessing }
Golap >> model: aGolapModel [
	self model: aGolapModel forceUpdate: true
]

{ #category : #accessing }
Golap >> model: aGolapModel forceUpdate: aBoolean [

	(aBoolean == false and: [ aGolapModel == model ]) ifTrue: [ ^ self ].
	self
		updateGlobalImageAfter: [ 
			(model notNil and: [ aGolapModel notNil ]) ifTrue: [ 
				model vertices keysAndValuesDo: [ :id :v1 | 
					(aGolapModel vertexAt: id ifAbsent: [ nil ]) ifNotNil: [ :v2 | 
						v2
							x: v1 x;
							y: v1 y ] ] ].
			model := aGolapModel.
			self overviewRenderer layouter model: model.
			self unselectAll.
			model ifNotNil: [ 
				edgesAppearancePresenter updateModel: model.
				itemList updateVertexList ] ]
		layout: true
]

{ #category : #'accessing-colors' }
Golap >> negativePolishColor [
	^ colorsAppearancePresenter negativePolishColor
]

{ #category : #'instance creation' }
Golap >> newGolapItemList [

	^ (self instantiate: GolapItemList)
		  golap: self;
		  yourself
]

{ #category : #'instance creation' }
Golap >> newGolapItemView [

	^ (self instantiate: GolapItemView)
		  golap: self;
		  authenticateBlock: self authenticateBlock;
		  yourself
]

{ #category : #'accessing-colors' }
Golap >> normalColor [
	^ colorsAppearancePresenter normalColor
]

{ #category : #'accessing-colors' }
Golap >> normalColorFor: aGolapVertex [
	^ colorsAppearancePresenter normalColorFor: aGolapVertex
]

{ #category : #accessing }
Golap >> numFriends [
	edgesAppearancePresenter numFriends
]

{ #category : #accessing }
Golap >> numFriends: anInteger [
	edgesAppearancePresenter numFriends: anInteger
]

{ #category : #accessing }
Golap >> numLabels [
	^ itemsAppearancePresenter numLabels
]

{ #category : #'instance creation' }
Golap >> open [

	| window |
	window := super open.
	self startPhotoimageRetrievingProcess.
	^ window
]

{ #category : #operations }
Golap >> openPresetQueryDialog [

	| presetQueries queryList |
	presetQueries := self readPresetQueries.
	queryList := SpEditableListPresenter new.
	queryList
		title: '商品名フィルタ';
		items: presetQueries asOrderedCollection;
		addItemBlock: [ UIManager default request: '新規パターン' ];
		removeItemBlock: [ 
			queryList selectedItem ifNotNil: [ :selection | 
					queryList items remove: selection ifAbsent: [  ].
					queryList refresh ] ];
		whenSelectionChangedDo: [ 
			([ queryList selectedItem ]
				 on: Error
				 do: [ :ex | ex return: nil ]) ifNotNil: [ :selection | 
					itemList queryField text: selection ] ];
		okAction: [ 
			queryList items asArray ~= presetQueries ifTrue: [ 
					self writePresetQueries: queryList items asArray ].
			([ queryList selectedItem ]
				 on: Error
				 do: [ :ex | ex return: nil ]) ifNotNil: [ :selection | 
					itemList queryField text: selection ] ];
		openModalWithSpec
]

{ #category : #'accessing-widgets' }
Golap >> overridesYWithFrequencyCheckbox [
	^ overridesYWithFrequencyCheckbox
]

{ #category : #'accessing-renderer' }
Golap >> overviewRenderer [
	^ overviewRenderer
		ifNil: [ overviewRenderer := GolapOverviewRenderer on: self ]
]

{ #category : #'operations-photoimages' }
Golap >> photoimageSize [

	^ 64
]

{ #category : #'accessing-colors' }
Golap >> pinColor [
	^ Color red
]

{ #category : #enumerating }
Golap >> pinsDo: aBlock [
	model
		ifNotNil: [ pins
				do:
					[ :id | (model vertexAt: id ifAbsent: [  ]) ifNotNil: aBlock ] ]
]

{ #category : #operations }
Golap >> pmiMode [
	edgesAppearancePresenter pmiMode
]

{ #category : #'accessing-colors' }
Golap >> positivePolishColor [
	^ colorsAppearancePresenter positivePolishColor
]

{ #category : #'accessing-presets' }
Golap >> presetQueryFile [
	^ self golapDirectory / 'presetQueries.json'
]

{ #category : #accessing }
Golap >> query [
	^ query
]

{ #category : #accessing }
Golap >> query: aDictionary [

	self setQuery: aDictionary
]

{ #category : #menu }
Golap >> queryViewTreeMenu [
	^ self newMenu
		addGroup: [ :group | 
			group
				addItem: [ :item | 
					item
						name: 'Copy all' translated;
						action: [ self copyAllFromQueryViewTree ] ];
				addItem: [ :item | 
					item
						name: 'Copy selected item' translated;
						action: [ self copyFromQueryViewTree ] ] ]
]

{ #category : #private }
Golap >> readDimensionFrom: aReadStream [

	| line index name status numItems dataframe columnNames isolatedNodesHeader position numHiddenItems dimension |
	line := aReadStream upTo: Character lf.
	index := line indexOf: $:.
	index = 0 ifTrue: [ ^ nil ].
	('status:'
		 ifEmpty: [ true ]
		 ifNotEmpty: [ line beginsWith: 'status:' caseSensitive: false ])
		ifTrue: [ name := 'no dimensions' ]
		ifFalse: [ 
			name := line.
			line := aReadStream upTo: Character lf ].
	status := Integer readFrom: (line readStream
			           upToAll: 'status:';
			           skipSeparators;
			           yourself).
	status < 0 ifTrue: [ 
		UIManager default alert: line , ' ' , aReadStream upToEnd.
		self delete.
		^ self ].
	status = 2 ifTrue: [ 
		UIManager default alert: 'Server timeout'.
		self delete.
		^ self ].
	numItems := Integer readFrom: (line readStream
			             upToAll: 'sent:';
			             skipSeparators).
	numHiddenItems := (line readStream
		                   upToAll: 'diff:';
		                   atEnd)
		                  ifTrue: [ 0 ]
		                  ifFalse: [ 
			                  Integer readFrom: (line readStream
					                   upToAll: 'diff:';
					                   skipSeparators) ].
	UIManager default
		displayProgress: 'reading ' , name
		from: 1
		to: numItems + numHiddenItems
		during: [ :progress | 
			dataframe := DataFrame
				             readFromCsv: (String lf join:
						              { ((aReadStream upTo: Character lf) , ',effective') }
						              , ((1 to: numItems) collect: [ :i | 
								               progress current: i.
								               (aReadStream upTo: Character lf) , ',1' ])
						              , ((1 to: numHiddenItems) collect: [ :i | 
								               progress current: i + numItems.
								               (aReadStream upTo: Character lf) , ',0' ]))
				             forceStringColumns:
				             #( 'node1' 'node2' 'node1n' 'node2n' ) asSet ].
	dataframe columnNames:
		(columnNames := dataframe columnNames collect: [ :string | 
			                (string includes: $%)
				                ifTrue: [ 
				                string copyFrom: 1 to: (string indexOf: $%) - 1 ]
				                ifFalse: [ string ] ]).
	isolatedNodesHeader := String streamContents: [ :stream | 
		                       stream
			                       nextPut: Character lf;
			                       nextPutAll: '## isolated nodes ##';
			                       nextPut: Character lf;
			                       nextPutAll: 'sent:' ].
	position := aReadStream position.
	(aReadStream next: isolatedNodesHeader size) = isolatedNodesHeader
		ifTrue: [ 
			| numNodes rows |
			numNodes := (aReadStream upTo: Character lf) trim asNumber.
			rows := Array streamContents: [ :stream | 
				        (DataFrame
					         readFromCsv: (String lf join:
							          ((0 to: numNodes) collect: [ :i | 
								           aReadStream upTo: Character lf ]))
					         forceStringColumns: #( 'node' 'noden' ) asSet) do: [ 
					        :row | 
					        stream nextPut: ((DataSeries
							          withKeys: dataframe columnNames
							          values: (dataframe columnNames collect: [ :n | 0 ]))
							         at: 'node1' put: (row at: 'node');
							         at: 'node1n' put: (row at: 'noden');
							         at: 'node2' put: nil;
							         at: 'node2n' put: String new;
							         at: 'frequency1' put: (row at: 'frequency');
							         name: { 
									         (row at: 'node').
									         nil };
							         yourself) ] ].
			dataframe := DataFrame
				             withRows: dataframe asArrayOfRows , rows
				             columnNames: columnNames ]
		ifFalse: [ aReadStream position: position ].
	{ 'frequency'. 'total' } do: [ :key | 
		| column newColumn |
		column := dataframe column: key.
		newColumn := column collect: [ :value | value ifNaN: [ 0 ] ].
		dataframe column: key put: newColumn ].
	{ 'support'. 'confidence'. 'lift'. 'jaccard' } do: [ :key | 
		| column newColumn |
		column := dataframe column: key.
		newColumn := column collect: [ :value | value ifNaN: [ 0.0 ] ].
		dataframe column: key put: newColumn ].
	dimension := GolapModel dataframe: dataframe.
	edgesAppearancePresenter updateModel: dimension.
	self silentAddDimension: dimension named: name.
	[ aReadStream peekFor: Character lf ] whileTrue
]

{ #category : #'accessing-presets' }
Golap >> readPresetQueries [
	[ self presetQueryFile ensureCreateFile
		readStreamDo: [ :stream | ^ (NeoJSONReader on: stream) next ] ]
		on: Error
		do: [ :ex | ^ Array new ]
]

{ #category : #private }
Golap >> regexFor: aString [
	| regex |
	regex := #('\' '.' '[' ']' '(' ')' '!' '+')
		inject: aString
		into: [ :p :special | p copyReplaceAll: special with: '\' , special ].
	^ ((regex copyReplaceAll: '*' with: '.*')
		copyReplaceAll: '?'
		with: '[ -~]+') asRegex
]

{ #category : #initialization }
Golap >> release [
	dimensions := nil.
	frontList := nil.
	baseList := nil.
	model := nil.
	overviewRenderer := nil.
	elaborationRenderer := nil.
	visibleEdges := nil.
	globalImagePane := nil.
	pins := nil.
	selections := nil.
	layoutButton := nil.
	zoomInButton := nil.
	zoomOutButton := nil.
	resetZoomButton := nil.
	globalMapPane := nil.
	font := nil.
	itemView := nil.
	super release
]

{ #category : #'accessing-renderer' }
Golap >> renderer [
	^ self perform: rendererSelector
]

{ #category : #operations }
Golap >> resendQuery [

	| client overview |
	client := GolapApiClient
		          url: self url
		          query: (NeoJSONWriter toString: self query)
		          authenticateBlock: self authenticateBlock.
	overview := Golap new
		            url: self url;
		            yourself.
	self snapshotDirectory copyAllTo:
		overview snapshotDirectory ensureDeleteAll.
	overview snapshotDirectory / 'createdTime' writeStreamDo: [ :stream | 
		| now |
		now := DateAndTime now.
		stream nextPutAll: now asDate printString , ' ' , now asTime print24 ].
	overview open title: overview snapshotDirectory basename.
	overview snapshotData: client readStream do: [ :readStream |  ].
	overview restoreSnapshot: overview snapshotDirectory
]

{ #category : #private }
Golap >> resetVisibleEdgeThresholds [
	edgesAppearancePresenter resetVisibleEdgeThresholds 
]

{ #category : #operations }
Golap >> resetZoom [
	self
		updateGlobalImageAfter: [ self renderer resetZoom]
]

{ #category : #snapshot }
Golap >> restoreColorsAppearance [

	| ref |
	ref := self snapshotDirectory / 'appearance-colors.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			colorsAppearancePresenter restore: stream ] ]
]

{ #category : #snapshot }
Golap >> restoreData [

	| ref |
	ref := self snapshotDirectory / 'data.csv'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :readStream | 
			[ readStream atEnd ] whileFalse: [ 
				self readDimensionFrom: readStream ] ].
		self updateDimensions ]
]

{ #category : #snapshot }
Golap >> restoreEdgesAppearance [

	| ref |
	ref := self snapshotDirectory / 'appearance-edges.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			edgesAppearancePresenter restore: stream ] ]
]

{ #category : #snapshot }
Golap >> restoreElaborationRenderer [

	| ref |
	ref := self snapshotDirectory / 'renderer-elaboration.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			self elaborationRenderer restore: stream ] ]
]

{ #category : #snapshot }
Golap >> restoreItemList [

	| ref |
	ref := self snapshotDirectory / 'item-list.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | itemList restore: stream ] ]
]

{ #category : #snapshot }
Golap >> restoreItemView [

	| ref |
	ref := self snapshotDirectory / 'item-view.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | itemView restore: stream ] ]
]

{ #category : #snapshot }
Golap >> restoreItemsAppearance [

	| ref |
	ref := self snapshotDirectory / 'appearance-items.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			itemsAppearancePresenter restore: stream ] ]
]

{ #category : #snapshot }
Golap >> restoreMerges [

	| ref |
	ref := self snapshotDirectory / 'merges.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			(NeoJSONReader on: stream) next ifNotNil: [ :json | 
				merges := json collect: [ :pair | pair first -> pair second ] ] ] ]
]

{ #category : #snapshot }
Golap >> restoreOverviewRenderer [

	| ref |
	ref := self snapshotDirectory / 'renderer-overview.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			self overviewRenderer restore: stream ] ]
]

{ #category : #snapshot }
Golap >> restoreQuery [

	| ref |
	ref := self snapshotDirectory / 'query.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			(NeoJSONReader on: stream) next ifNotNil: [ :json | 
				(json at: 'url' ifAbsent: [ nil ]) ifNotNil: [ :string | 
					url := string asUrl ].
				(json at: 'query' ifAbsent: [ nil ]) ifNotNil: [ :dictionary | 
					self setQuery: dictionary ] ] ] ]
]

{ #category : #snapshot }
Golap >> restoreSelections [

	| ref |
	ref := self snapshotDirectory / 'selections.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			(NeoJSONReader on: stream) next
				at: 'renderer' ifPresent: [ :string | 
					string = 'elaborationRenderer'
						ifTrue: [ self setElaborationRenderer ]
						ifFalse: [ self setOverviewRenderer ] ];
				at: 'pins' ifPresent: [ :array | pins := array asSet ];
				at: 'frontDimension'
				ifPresent: [ :string | frontList selectItem: string ];
				at: 'baseDimension'
				ifPresent: [ :string | baseList selectItem: string ];
				at: 'selections' ifPresent: [ :array | 
					selections := array asSet.
					selectedEdges := nil ] ] ]
]

{ #category : #snapshot }
Golap >> restoreSnapshot: aFileReference [

	self window ifNotNil: [ :w | w title: aFileReference basename ].
	snapshotDirectory := aFileReference.
	self disableSnapshotWhile: [ 
		self
			updateGlobalImageAfter: [ 
				self
					restoreQuery;
					restoreItemList;
					restoreItemView;
					restoreElaborationRenderer;
					restoreOverviewRenderer;
					restoreMerges;
					restoreData;
					restoreSelections;
					restoreColorsAppearance;
					restoreEdgesAppearance;
					restoreItemsAppearance;
					yourself ]
			layout: true ].
	self updateGlobalImageAfter: [  ] layout: true
]

{ #category : #'accessing-colors' }
Golap >> retreatingColor [
	^ colorsAppearancePresenter retreatingColor
]

{ #category : #'operations-photoimages' }
Golap >> retrievePhotoimage [

	rendererSelector = #overviewRenderer ifTrue: [ 
		self retrievePhotoimageOnOverviewRenderer ].
	rendererSelector = #elaborationRenderer ifTrue: [ 
		self retrievePhotoimageOnElaborationRenderer ]
]

{ #category : #'operations-photoimages' }
Golap >> retrievePhotoimageFor: aGolapVertex [

	aGolapVertex photoimage: false.
	[ retrievalProcessCount > self maxPhotoimageRetrievalProcesses ] 
		whileTrue: [ 300 milliSecond wait ].
	retrievalProcessCount := retrievalProcessCount + 1.
	[ 
	itemView ifNotNil: [ 
		[ 
		(itemView retrieveSingleImageFor: aGolapVertex data value) 
			ifNotNil: [ :image | 
				aGolapVertex photoimage:
					(image scaledToSize: self photoimageSize asPoint).
				self updateGlobalImageAfter: [  ] ] ] ensure: [ 
			retrievalProcessCount := retrievalProcessCount - 1 ] ] ] forkAt:
		Processor userBackgroundPriority - 5
]

{ #category : #'operations-photoimages' }
Golap >> retrievePhotoimageOnElaborationRenderer [

	[ 
	elaborationRenderer ifNotNil: [ 
		overviewRenderer verticesDo: [ :vertex | 
			vertex basicPhotoimage ifNil: [ 
				^ self retrievePhotoimageFor: vertex ].
			Processor yield ] ] ]
		on: Error
		do: [ :ex |  ]
]

{ #category : #'operations-photoimages' }
Golap >> retrievePhotoimageOnOverviewRenderer [

	[ 
	overviewRenderer ifNotNil: [ 
		globalImagePane withAdapterDo: [ :a | 
			a widgetDo: [ :w | 
				| origin corner mouse minD minV |
				origin := overviewRenderer vertexPointAtPoint:
					          (-10 @ -10 min: w extent // 10).
				corner := overviewRenderer vertexPointAtPoint:
					          w extent + (10 @ 10 max: w extent // 10).
				mouse := overviewRenderer vertexPointAtPoint:
					         w activeHand position - w position.
				minD := Float infinity.
				minV := nil.
				overviewRenderer reallyVisibleVerticesDo: [ :vertex | 
					vertex basicPhotoimage ifNil: [ 
						vertex x ifNotNil: [ :x | 
							vertex y ifNotNil: [ :y | 
								((x between: origin x and: corner x) and: [ 
									 y between: origin y and: corner y ]) ifTrue: [ 
									| d |
									d := (x - mouse x) squared + (y - mouse y) squared.
									d < minD ifTrue: [ 
										minD := d.
										minV := vertex ] ] ] ] ].
					Processor yield ].

				minV ifNotNil: [ ^ self retrievePhotoimageFor: minV ] ] ] ] ]
		on: Error
		do: [ :ex |  ]
]

{ #category : #operations }
Golap >> saveAsSVG [
	(UIManager default
		chooseForSaveFileReference: 'Save as a SVG file'
		extensions: #('svg')
		path: self golapDirectory)
		ifNotNil: [ :fileReference | 
			fileReference
				writeStreamDo: [ :stream | self renderer svg printWithPrologOn: stream ] ]
]

{ #category : #operations }
Golap >> saveFullImage [

	(UIManager default
		 chooseForSaveFileReference: 'Save as a PNG file'
		 extensions: #( 'png' )
		 path: self golapDirectory) ifNotNil: [ :fileReference | 
		fileReference binaryWriteStreamDo: [ :stream | 
			Cursor wait showWhile: [ 
				PNGReadWriter putForm: self renderer fullImage onStream: stream ] ] ]
]

{ #category : #snapshot }
Golap >> saveSnapshot [

	| newSnapshotRef |
	newSnapshotRef := self snapshotBaseDirectory / ((UIManager default
		                    request: 'スナップショット名'
		                    initialAnswer: (self isTemporarySnapshot
				                     ifTrue: [ '' ]
				                     ifFalse: [ self snapshotDirectory basename ])) 
		                   ifNil: [ ^ self ]).
	newSnapshotRef ~= self snapshotDirectory ifTrue: [ 
		newSnapshotRef exists ifTrue: [ 
			(UIManager confirm: newSnapshotRef basename , 'は既に存在しています。上書きしますか？')
				ifTrue: [ newSnapshotRef ensureDeleteAll ]
				ifFalse: [ ^ self ] ].
		self snapshotDirectory copyAllTo: newSnapshotRef.
		(self isTemporarySnapshot or: [ 
			 UIManager confirm: self snapshotDirectory basename , 'を削除しますか？' ]) 
			ifTrue: [ self snapshotDirectory ensureDeleteAll ].
		snapshotDirectory := newSnapshotRef ].
	self snapshotGlobalImage.
	self snapshotMerges.
	self snapshotSelections.
	colorsAppearancePresenter snapshot.
	edgesAppearancePresenter snapshot.
	itemsAppearancePresenter snapshot.
	itemList snapshot.
	itemView snapshot.
	elaborationRenderer ifNotNil: #snapshot.
	overviewRenderer ifNotNil: #snapshot
]

{ #category : #'accessing-selection' }
Golap >> select: aGolapVertex [

	self updateGlobalImageAfter: [ 
		aGolapVertex dataDo: [ :data | selections add: data ].
		selectedEdges := nil.
		self showItemView: aGolapVertex ]
]

{ #category : #'accessing-dimensions' }
Golap >> selectedBaseDimension [
	^ dimensions at: baseList selectedItem ifAbsent: [ nil ]
]

{ #category : #accessing }
Golap >> selectedEdges [
	^ selectedEdges
		ifNil: [ | edges |
			edges := IdentitySet new: selections size.
			self selections do: [ :v | v edgesDo: [ :e | edges add: e ] ].
			selectedEdges := edges asArray ]
]

{ #category : #'accessing-dimensions' }
Golap >> selectedFrontDimension [
	^ dimensions at: frontList selectedItem ifAbsent: [ nil ]
]

{ #category : #'accessing-dimensions' }
Golap >> selectedModel [

	^ (self selectedFrontDimension ifNil: [ nil ] ifNotNil: [ :front | 
		   self selectedBaseDimension ifNil: [ front ] ifNotNil: [ :base | 
			   self
				   applyMergesToModel: front;
				   applyMergesToModel: base.
			   front - base ] ]) ifNotNil: [ :m | self applyMergesToModel: m ]
]

{ #category : #enumerating }
Golap >> selectedVerticesDo: aBlock [
	model
		verticesDo: [ :vertex | 
			(selections anySatisfy: [ :data | vertex hasData: data ])
				ifTrue: [ aBlock value: vertex ] ]
]

{ #category : #'accessing-colors' }
Golap >> selectionColor [
	^ colorsAppearancePresenter selectionColor
]

{ #category : #'accessing-selection' }
Golap >> selections [
	^ Array
		streamContents: [ :stream | 
			model
				verticesDo: [ :v | 
					(selections anySatisfy: [ :id | v hasData: id ])
						ifTrue: [ stream nextPut: v ] ] ]
]

{ #category : #'accessing-selection' }
Golap >> selectionsAdd: aGolapVertex [

	self updateGlobalImageAfter: [ 
		aGolapVertex dataDo: [ :data | selections add: data ].
		selectedEdges := nil ]
]

{ #category : #'accessing-selection' }
Golap >> selectionsAddAll: aCollectionOfGolapVertex [

	self updateGlobalImageAfter: [ 
		aCollectionOfGolapVertex do: [ :vertex | 
			vertex dataDo: [ :data | selections add: data ] ].
		selectedEdges := nil ]
]

{ #category : #'accessing-renderer' }
Golap >> setElaborationRenderer [

	self updateGlobalImageAfter: [ 
		rendererSelector := #elaborationRenderer.
		elaborationRendererButton state: true.
		overviewRendererButton state: false ]
]

{ #category : #'accessing-renderer' }
Golap >> setOverviewRenderer [

	self
		updateGlobalImageAfter: [ 
			rendererSelector := #overviewRenderer.
			elaborationRendererButton state: false.
			overviewRendererButton state: true ]
		layout: (self vertices anySatisfy: [ :v | v asPoint isNil ])
]

{ #category : #accessing }
Golap >> setQuery: aDictionary [

	query := aDictionary.

	queryViewTree roots:
		(query keys asSortedCollection collect: [ :key | 
			 key -> (query at: key) ]).
	itemView ifNotNil: [ itemView query: aDictionary ]
]

{ #category : #operations }
Golap >> showItemView: aGolapVertex [
	aGolapVertex ifNotNil: [ itemView vertex: aGolapVertex ]
]

{ #category : #accessing }
Golap >> showsConnectedVertices [
	^ itemsAppearancePresenter showsConnectedVertices
]

{ #category : #accessing }
Golap >> showsHiddenConnectionVertices [
	^ itemsAppearancePresenter showsHiddenConnectionVertices
]

{ #category : #accessing }
Golap >> showsIsolatedVertices [
	^ itemsAppearancePresenter showsIsolatedVertices
]

{ #category : #'accessing-dimensions' }
Golap >> silentAddDimension: aGolapOverviewModel named: aString [
	dimensions at: aString put: aGolapOverviewModel.
	^ aGolapOverviewModel
]

{ #category : #private }
Golap >> simpleStringFor: aNumber [
	aNumber isNil
		ifTrue: [ ^ '' ].
	aNumber isNumber
		ifFalse: [ ^ aNumber printString ].
	aNumber isInteger
		ifTrue: [ ^ aNumber printString ].
	aNumber isInfinite
		ifTrue: [ aNumber > 0.0
				ifTrue: [ ^ '+∞' ]
				ifFalse: [ ^ '-∞' ] ].
	aNumber isNaN
		ifTrue: [ ^ 'NaN' ].
	^ aNumber printShowingDecimalPlaces: 4
]

{ #category : #snapshot }
Golap >> snapshotBaseDirectory [

	^ (self golapDirectory / self snapshotBaseDirectoryName)
		  ensureCreateDirectory;
		  yourself
]

{ #category : #snapshot }
Golap >> snapshotBaseDirectoryName [

	^ 'snapshots'
]

{ #category : #snapshot }
Golap >> snapshotColorsAppearance: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'appearance-colors.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : #snapshot }
Golap >> snapshotData: aReadStream do: aBlock [

	self snapshotQuery.
	aReadStream
		ifNotNil: [ 
			self snapshotDirectory
				ifNotNil: [ :baseDir | 
					| ref |
					ref := (baseDir / 'data.csv') ensureDelete.
					ref writeStreamDo: [ :writeStream | 
						Cursor wait showWhile: [ 
							UIManager default informUserDuring: [ :bar | 
								bar
									min: 0;
									max: aReadStream size.
								[ aReadStream atEnd ] whileFalse: [ 
									bar value: aReadStream position.
									writeStream nextPutAll: (aReadStream next: 16384) ] ] ] ].
					ref readStreamDo: [ :readStream | aBlock value: readStream ] ]
				ifNil: [ aBlock value: aReadStream ] ]
		ifNil: [ aBlock value: nil ]
]

{ #category : #snapshot }
Golap >> snapshotDirectory [

	^ (snapshotDirectory ifNil: [ 
		   snapshotDirectory := self createTemporarySnapshotDirectory ifNil: [ ^ nil ] ])
		  ensureCreateDirectory
]

{ #category : #snapshot }
Golap >> snapshotEdgesAppearance: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'appearance-edges.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : #snapshot }
Golap >> snapshotElaborationRenderer: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'renderer-elaboration.json') ensureDelete 
				writeStreamDo: [ :writeStream | aBlock value: writeStream ] ] ]
]

{ #category : #snapshot }
Golap >> snapshotGlobalImage [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			globalImagePane image ifNotNil: [ :image | 
				[ 
				(baseDir / 'globalImage.png.tmp') ensureDelete 
					binaryWriteStreamDo: [ :stream | 
					(PNGReadWriter on: stream) nextPutImage: image ].
				(baseDir / 'globalImage.png') ensureDelete.
				baseDir / 'globalImage.png.tmp' renameTo: 'globalImage.png' ]
					on: FileException
					do: [ :ex |  ] ] ] ]
]

{ #category : #snapshot }
Golap >> snapshotItemList: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'item-list.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : #snapshot }
Golap >> snapshotItemView: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'item-view.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : #snapshot }
Golap >> snapshotItemsAppearance: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'appearance-items.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : #snapshot }
Golap >> snapshotMerges [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'merges.json') ensureDelete writeStreamDo: [ :stream | 
				(NeoJSONWriter on: stream) nextPut: (merges collect: [ :assoc | 
						 { 
							 assoc key.
							 assoc value } ]) ] ] ]
]

{ #category : #snapshot }
Golap >> snapshotOverviewRenderer: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'renderer-overview.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : #snapshot }
Golap >> snapshotQuery [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			| queryJson |
			queryJson := Dictionary new.
			url ifNotNil: [ queryJson at: 'url' put: url printString ].
			query ifNotNil: [ queryJson at: 'query' put: query ].
			(baseDir / 'query.json') ensureDelete writeStreamDo: [ :stream | 
				(NeoJSONWriter on: stream) nextPut: queryJson ] ] ]
]

{ #category : #snapshot }
Golap >> snapshotSelections [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'selections.json') ensureDelete writeStreamDo: [ 
				:writeStream | 
				(NeoJSONWriter on: writeStream) nextPut: { 
						('renderer' -> rendererSelector) .
						('selections' -> selections).
						('pins' -> pins).
						('frontDimension' -> frontList selectedItem).
						('baseDimension' -> baseList selectedItem) } asOrderedDictionary ] ] ]
]

{ #category : #'operations-photoimages' }
Golap >> startPhotoimageRetrievingProcess [

	self stopPhotoimageRetrievingProcess.
	photoImageRetrievingProcess := [ 
	                               retrievalProcessCount := 0.
	                               [ 
	                               self ifNotActive: [ 
		                               photoImageRetrievingProcess := nil.
		                               Processor activeProcess terminate ].
	                               self retrievePhotoimage.
	                               100 milliSecond wait ] repeat ] 
		                               forkAt:
		                               Processor userBackgroundPriority
]

{ #category : #'operations-photoimages' }
Golap >> stopPhotoimageRetrievingProcess [

	photoImageRetrievingProcess ifNotNil: [ 
		photoImageRetrievingProcess terminate.
		photoImageRetrievingProcess := nil ]
]

{ #category : #operations }
Golap >> sumMode [
	edgesAppearancePresenter sumMode
]

{ #category : #snapshot }
Golap >> temporaryDirectoryName [

	^ 'temporary'
]

{ #category : #accessing }
Golap >> title [

	^ (self basicSnapshotDirectory notNil and: [ 
		   self isTemporarySnapshot not ])
		  ifTrue: [ self snapshotDirectory basename ]
		  ifFalse: [ 'gOLAP' ]
]

{ #category : #'accessing-selection' }
Golap >> togglePin: aGolapVertex [

	self updateGlobalImageAfter: [ 
		| id |
		id := aGolapVertex data.
		(pins includes: id)
			ifTrue: [ pins remove: id ]
			ifFalse: [ pins add: id ] ]
]

{ #category : #'accessing-selection' }
Golap >> toggleSelection: aGolapVertex [
	self
		updateGlobalImageAfter: [ (self includesSelection: aGolapVertex)
				ifTrue: [ self unselect: aGolapVertex ]
				ifFalse: [ self select: aGolapVertex ] ]
]

{ #category : #'accessing-dimensions' }
Golap >> totalModel [
	| models totalModel |
	models := dimensions values asArray.
	models isEmpty
		ifTrue: [ ^ self ].
	totalModel := models first copy.
	2 to: models size do: [ :index | totalModel := totalModel + (models at: index) ].
	self model: totalModel
]

{ #category : #accessing }
Golap >> treeEdges [
	^ model ifNotNil: [ model treeEdges ] ifNil: [ Array new ]
]

{ #category : #menu }
Golap >> unmergeMenu [
	| menu |
	menu := self newMenu.
	menu
		addGroup: [ :group | 
			merges
				do: [ :assoc | 
					group
						addItem: [ :item | 
							item
								name: assoc key;
								action: [ self unmergeVertex: assoc key ] ] ] ].
	^ menu
]

{ #category : #merging }
Golap >> unmergeVertex: aString [

	merges removeAllSuchThat: [ :assoc | assoc key = aString ].
	self updateModel.
	itemList updateVertexList
]

{ #category : #'accessing-selection' }
Golap >> unselect: aGolapVertex [

	self updateGlobalImageAfter: [ 
		aGolapVertex dataDo: [ :data | 
			selections remove: data ifAbsent: [  ] ].
		selectedEdges := nil ]
]

{ #category : #'accessing-selection' }
Golap >> unselectAll [

	self updateGlobalImageAfter: [ 
		selections removeAll.
		selectedEdges := nil ]
]

{ #category : #'accessing-dimensions' }
Golap >> updateDimensions [
	frontList
		items: dimensions keys;
		selectItem: dimensions keys last
]

{ #category : #drawing }
Golap >> updateGlobalImage [

	drawingSemaphore critical: [ 
		| imageAndMap |
		imageAndMap := self renderer globalImageAndMap.
		globalImagePane image: imageAndMap first.
		globalMapPane image: imageAndMap second ].
	self ensurePhotoimageRetrievingProcess
]

{ #category : #drawing }
Golap >> updateGlobalImageAfter: aBlock [
	^ self updateGlobalImageAfter: aBlock layout: false
]

{ #category : #drawing }
Golap >> updateGlobalImageAfter: aBlock layout: aBoolean [

	| sender |
	sender := thisContext sender.
	aBlock ensure: [ 
		[ sender notNil ] whileTrue: [ 
			sender selector = #updateGlobalImageAfter:layout: ifTrue: [ ^ self ].
			sender := sender sender ].
		aBoolean = true ifTrue: [ self basicLayout ].
		self updateGlobalImage ]
]

{ #category : #operations }
Golap >> updateItemView [
	self
		showItemView:
			(model
				vertexAt: itemList selectedItem
				ifAbsent: [ ^ self ])
]

{ #category : #operations }
Golap >> updateModel [
	self model: self selectedModel
]

{ #category : #private }
Golap >> updateQuery [
	itemList updateVertexList
]

{ #category : #'accessing-selection' }
Golap >> updateSelection [
	self updateGlobalImageAfter: [  ]
]

{ #category : #accessing }
Golap >> url [
	^ url
]

{ #category : #accessing }
Golap >> url: aZnUrl [

	url := aZnUrl asUrl
]

{ #category : #accessing }
Golap >> vertices [
	^ model ifNil: [ #() ] ifNotNil: [ model vertices values ]
]

{ #category : #enumerating }
Golap >> verticesDo: aBlock [
	model ifNotNil: [ model vertices valuesDo: aBlock ]
]

{ #category : #'accessing-widgets' }
Golap >> visibleEdgeMaxPercentile [
	^ edgesAppearancePresenter ifNotNil: #visibleEdgeMaxPercentile
]

{ #category : #'accessing-widgets' }
Golap >> visibleEdgeMinPercentile [
	^ edgesAppearancePresenter ifNotNil: #visibleEdgeMinPercentile
]

{ #category : #accessing }
Golap >> visibleEdges [
	^ visibleEdges ifNil: [ edgesAppearancePresenter visibleEdges ]
]

{ #category : #private }
Golap >> writeCSVOn: aStream [
	self writeCSVOn: aStream progressBlock: [ :v |  ]
]

{ #category : #private }
Golap >> writeCSVOn: aStream progressBlock: aBlock [
	| writer scale base |
	writer := (NeoCSVWriter on: aStream)
		separator: $,;
		lineEndConvention: #lf.
	dimensions ifEmpty: [ ^ self ].
	scale := 1.0 / dimensions size.
	base := 0.0.
	dimensions
		keysAndValuesDo: [ :d :m | 
			| dataframe numRows rowCount |
			dataframe := m dataframe.
			dimensions size > 1
				ifTrue: [ aStream
						nextPutAll: d;
						nextPut: Character lf ].
			aStream
				nextPutAll: 'status:0 sent:';
				nextPutAll: dataframe size printString;
				nextPut: Character lf.
			dataframe columnNames allButLast
				do: [ :n | aStream nextPutAll: n ]
				separatedBy: [ aStream nextPut: $, ].
			aStream nextPut: Character lf.
			numRows := dataframe size.
			rowCount := 0.
			dataframe
				do: [ :rawRow | 
					| row |
					row := rawRow asDataSeries.
					row removeKey: 'effective' ifAbsent: [  ].
					(rowCount := rowCount + 1) \\ 100 = 0
						ifTrue: [ aBlock value: rowCount asFloat / numRows asFloat * scale + base ].
					aStream
						nextPutAll:
							(','
								join:
									(row
										withKeyCollect: [ :v :k | 
											k last = $n
												ifTrue: [ '"' , (v copyReplaceAll: '"' with: '\"') , '"' ]
												ifFalse: [ v asString ] ]));
						nextPut: Character lf ] ].
	writer close
]

{ #category : #'accessing-presets' }
Golap >> writePresetQueries: anArrayOfString [
	self presetQueryFile ensureDelete
		writeStreamDo: [ :stream | ^ (NeoJSONWriter on: stream) nextPut: anArrayOfString ]
]

{ #category : #operations }
Golap >> zoomIn [

	(lastZoomTimestamp notNil and: [ 
		 DateAndTime now - lastZoomTimestamp < 0.1 seconds ]) ifTrue: [ 
		^ self ].
	lastZoomTimestamp := DateAndTime now.
	self updateGlobalImageAfter: [ self renderer zoomIn ]
]

{ #category : #operations }
Golap >> zoomInCenter [

	(lastZoomTimestamp notNil and: [ 
		 DateAndTime now - lastZoomTimestamp < 0.1 seconds ]) ifTrue: [ 
		^ self ].
	lastZoomTimestamp := DateAndTime now.
	self updateGlobalImageAfter: [ self renderer zoomInCenter ]
]

{ #category : #operations }
Golap >> zoomOut [

	(lastZoomTimestamp notNil and: [ 
		 DateAndTime now - lastZoomTimestamp < 0.1 seconds ]) ifTrue: [ 
		^ self ].
	lastZoomTimestamp := DateAndTime now.
	self updateGlobalImageAfter: [ self renderer zoomOut ]
]

{ #category : #operations }
Golap >> zoomOutCenter [

	(lastZoomTimestamp notNil and: [ 
		 DateAndTime now - lastZoomTimestamp < 0.1 seconds ]) ifTrue: [ 
		^ self ].
	lastZoomTimestamp := DateAndTime now.
	self updateGlobalImageAfter: [ self renderer zoomOutCenter ]
]
