Class {
	#name : 'Golap',
	#superclass : 'SpPresenter',
	#instVars : [
		'model',
		'productInfoRetriever',
		'queryRecord',
		'url',
		'query',
		'overviewRenderer',
		'elaborationRenderer',
		'viewsNotebook',
		'globalImagePane',
		'pins',
		'selections',
		'overridesYWithFrequencyCheckbox',
		'overridesYWithFrequencyOrderCheckbox',
		'layoutButton',
		'layoutChooseButton',
		'zoomInButton',
		'zoomOutButton',
		'resetZoomButton',
		'globalMapPane',
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
		'drawingSemaphore',
		'commentText',
		'openSunburstButton',
		'dandelionPresenter',
		'snapshotBaseName',
		'hedgePresenter',
		'dragNode',
		'edgeList'
	],
	#classVars : [
		'NameEndOfLineDelimiter'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'utilities' }
Golap class >> defaultFont [
	^ StandardFonts defaultFont
]

{ #category : 'utilities' }
Golap class >> defaultFont: aFont [
	^ StandardFonts defaultFont: aFont
]

{ #category : 'layout' }
Golap class >> defaultLayout [

	<spec>
	^ SpPanedLayout newHorizontal
		  positionOfSlider: 0.75;
		  add: #viewsNotebook;
		  add: (SpBoxLayout newVertical
				   add: #saveSnapshotButton height: self buttonHeight;
				   add: #saveAsSvgButton height: self buttonHeight;
				   add: #saveAsPngButton height: self buttonHeight;
				   add: #resentQueryButton height: self buttonHeight;
				   add: #queryViewTree height: 200;
				   add: #itemNotebook);
		  yourself
]

{ #category : 'utilities' }
Golap class >> deploy [

	<script>
	GolapNetworkClientPresenter flushCurrent.
	MCRepositoryGroup allSubInstancesDo: [ :group |
		group repositories do: [ :repo | group removeRepository: repo ] ].
	IceRepository registry removeAll.
	IceCredentialStore current in: [ :store |
		store allCredentials do: [ :each | each removeFrom: store ] ].
	self currentWorld closeAllWindowsDiscardingChanges.
	Deprecation
		raiseWarning: false;
		showWarning: false.
	NoChangesLog install.
	"NoPharoFilesOpener install."
	FFICompilerPlugin install.
	Stdio useNullStreams.
	MCCacheRepository uniqueInstance disable.
	EpMonitor reset.
	SessionManager default registerSystemClassNamed: #FreeTypeFileInfo.
	Golap allInstancesDo: [ :g | g becomeForward: Object new ].
	5 timesRepeat: [ "PharoCommandLineHandler forcePreferencesOmission: true"
		Smalltalk garbageCollect ]
]

{ #category : 'settings' }
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

{ #category : 'utilities' }
Golap class >> golapDirectory [

	^ (FileLocator documents / 'gOLAP') ensureCreateDirectory
]

{ #category : 'menus' }
Golap class >> golapMenuOn: aBuilder [

	<worldMenu>
	(aBuilder item: #Golap)
		label: 'gOLAP';
		order: 1;
		with: [
			(aBuilder item: #'Snapshot Browser')
				parent: 'Golap';
				order: 2;
				target: GolapSnapshotBrowser;
				selector: #open;
				help: 'Open a snapshot launcher';
				withSeparatorAfter.
			(aBuilder item: #'Open File...')
				parent: 'Golap';
				order: 3;
				target: self;
				selector: #openFile;
				help: 'Open a CSV file with dimensions';
				withSeparatorAfter.
			(aBuilder item: #'Open URL...')
				parent: 'Golap';
				order: 4;
				target: self;
				selector: #openNewClient;
				help:
					'Open a CSV file with dimensions from a server with a blank query'.
			(aBuilder item: #'Open URL again...')
				parent: 'Golap';
				order: 5;
				target: self;
				selector: #openClient;
				help:
					'Open a CSV file with dimensions from a server with the previous query';
				withSeparatorAfter.
			(aBuilder item: #'Settings...')
				parent: 'Golap';
				order: 6;
				target: self;
				selector: #showSettingBrowser;
				help: 'Open a settings dialog for gOLAP';
				withSeparatorAfter.
			(aBuilder item: #'About...')
				parent: 'Golap';
				order: 7;
				target: self;
				selector: #openAboutDialog;
				help: 'Open a logo image and version of this application';
				withSeparatorAfter ]
]

{ #category : 'accessing' }
Golap class >> nameEndOfLineDelimiter [
	^ NameEndOfLineDelimiter ifNil: [ '||' ]
]

{ #category : 'accessing' }
Golap class >> nameEndOfLineDelimiter: aString [
	NameEndOfLineDelimiter := aString
]

{ #category : 'utilities' }
Golap class >> open [

	<script: 'GolapOverview open'>
	| overview |
	overview := Golap new.
	overview open maximize.
	^ overview
		  updateGlobalImageAfter: [ overview model: nil ] layout: true;
		  yourself
]

{ #category : 'utilities' }
Golap class >> openAboutDialog [

	<script>
	BaselineOfGolap logoImageWithCodename asPresenter open
		title: 'about gOLAP ' , BaselineOfGolap codename;
		beNotResizable
]

{ #category : 'examples' }
Golap class >> openClient [

	<script: 'GolapOverview openClient'>
	| overview |
	overview := Golap new.
	overview open maximize.
	GolapNetworkClientPresenter
		openDialogIfAccepted: [ :client :queryRecord |
			[
			overview
				queryRecord: queryRecord;
				productInfoRetriever:
					(GolapServerProductInfoRetriever fromApiClient: client);
				authenticateBlock: client authenticateBlock;
				query: (NeoJSONReader fromString: client query);
				url: client url;
				comment: client comment;
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
											bar label: 'updating graph' ]
										layout: true.
									overview updateGlobalImageAfter: [  ] layout: true ] ] ] ] ] ]
		ifCanceled: [ overview delete ]
]

{ #category : 'examples' }
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
											bar label: 'updating graph' ]
										layout: true ] ] ] ] ]
			ifFalse: [ overview delete ] ].
	^ overview
]

{ #category : 'examples' }
Golap class >> openNewClient [
	<script: 'GolapDimensionsOverview openNewClient'>
	GolapNetworkClientPresenter flushCurrent.
	^ self openClient
]

{ #category : 'menus' }
Golap class >> showSettingBrowser [
	<script>
	SettingBrowser new
		changePackageSet:
			{(RPackageOrganizer default packageNamed: #'Network-Kernel').
			(RPackageOrganizer default packageNamed: #'Golap-UI')};
		open
]

{ #category : 'accessing-dimensions' }
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

{ #category : 'menu' }
Golap >> addReferenceNode: aGolapNode [

	overviewRenderer addReferenceNode: aGolapNode.
	self updateGlobalImage
]

{ #category : 'accessing-markers' }
Golap >> allMarkerColors [

	^ itemList allMarkerColors
]

{ #category : 'accessing-dimensions' }
Golap >> animateDimensions [

	(UIManager default
		 request: 'コマ送り間隔 (秒)'
		 initialAnswer: '1'
		 title: '流す...') ifNotNil: [ :string |
		[
		| seconds |
		seconds := string asNumber max: 0.
		[
		dimensions keysDo: [ :dimensionName |
			frontList selectItem: dimensionName.
			seconds second wait ] ] forkAt: Processor userBackgroundPriority ]
			on: Error
			do: [ :ex |  ] ]
]

{ #category : 'announcements' }
Golap >> announceGolapModelUpdated [

	self announcer announce: GolapModelUpdated new
]

{ #category : 'announcements' }
Golap >> announceGolapViewUpdated [

	self announcer announce: GolapViewUpdated new
]

{ #category : 'merging' }
Golap >> applyMergesToModel: aGolapModel [

	| positions |
	positions := Dictionary new:
		             (model
			              ifNil: [ 256 ]
			              ifNotNil: [ model nodes size * 3 // 2 ]).
	model ifNotNil: [
		model nodesDo: [ :node |
			node asPoint ifNotNil: [ :p | positions at: node id put: p ] ] ].
	aGolapModel resetNodes.
	aGolapModel nodesDo: [ :node |
		positions at: node id ifPresent: [ :p |
			node
				x: p x;
				y: p y ] ].
	merges do: [ :assoc |
		| oldNodes newNode |
		oldNodes := assoc value
			            collect: [ :id |
			            aGolapModel nodes at: id ifAbsent: [ nil ] ]
			            thenSelect: #notNil.
		newNode := aGolapModel
			           mergeNodes: (assoc value
					            collect: [ :id |
					            aGolapModel nodes at: id ifAbsent: [ nil ] ]
					            thenSelect: #notNil)
			           named: assoc key.
		newNode
			x: ((oldNodes collect: #x thenSelect: #notNil)
					 ifEmpty: [ nil ]
					 ifNotEmpty: #average);
			y: ((oldNodes collect: #y thenSelect: #notNil)
					 ifEmpty: [ nil ]
					 ifNotEmpty: #average) ].
	^ aGolapModel
]

{ #category : 'accessing' }
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

{ #category : 'accessing' }
Golap >> authenticateBlock: aBlock [

	authenticateBlock := aBlock.
	productInfoRetriever ifNotNil: [
		productInfoRetriever authenticateBlock: aBlock ]
]

{ #category : 'accessing-renderer' }
Golap >> basicLayout [

	self renderer
		overridesYWithFrequency: overridesYWithFrequencyCheckbox state;
		overridesYWithFrequencyOrder:
			overridesYWithFrequencyOrderCheckbox state;
		layout
]

{ #category : 'snapshot' }
Golap >> basicSnapshotDirectory [

	^ snapshotDirectory
]

{ #category : 'layouts' }
Golap >> buttonHeight [

	^ self class buttonHeight
]

{ #category : 'menu' }
Golap >> chooseLayouterMenu [

	^ self newMenu addGroup: [ :group |
		  group
			  addItem: [ :item |
				  item
					  name: 'ばね';
					  action: [ self springLayout ] ];
			  addItem: [ :item |
				  item
					  name: '円周（フレンドクラスタ）';
					  action: [ self friendClusteredLayout ] ];
			  yourself ]
]

{ #category : 'accessing-colors' }
Golap >> colorForEdge: aGolapEdge [

	((self includesSelection: aGolapEdge node1) or: [
		 self includesSelection: aGolapEdge node2 ]) ifTrue: [
		^ self selectionColor ].
	self selectedBaseDimension ifNotNil: [
		| frontEdge baseEdge v |
		frontEdge := self selectedFrontDimension
			             edgeBetween: aGolapEdge node1 id
			             and: aGolapEdge node2 id
			             ifAbsent: [  ].
		baseEdge := self selectedBaseDimension
			            edgeBetween: aGolapEdge node1 id
			            and: aGolapEdge node2 id
			            ifAbsent: [  ].
		(frontEdge isNil and: [ baseEdge notNil ]) ifTrue: [
			^ self retreatingColor ].
		(frontEdge notNil and: [ baseEdge isNil ]) ifTrue: [
			^ self freshColor ].
		v := model valueAtEdge: aGolapEdge.
		v < 0 ifTrue: [ ^ self decliningColor ].
		v > 0 ifTrue: [ ^ self growingColor ] ].
	^ self normalColor
]

{ #category : 'accessing-colors' }
Golap >> colorForNode: aGolapNode [

	(self includesSelection: aGolapNode) ifTrue: [
		^ self selectionColor ].
	self selectedBaseDimension ifNotNil: [
		| frontNode baseNode |
		frontNode := self selectedFrontDimension ifNotNil: [ :dimension |
			               dimension nodeAt: aGolapNode id ifAbsent: [  ] ].
		baseNode := self selectedBaseDimension ifNotNil: [ :dimension |
			              dimension nodeAt: aGolapNode id ifAbsent: [  ] ].
		(frontNode isNil and: [ baseNode notNil ]) ifTrue: [
			^ self retreatingColor ].
		(frontNode notNil and: [ baseNode isNil ]) ifTrue: [
			^ self freshColor ].
		(model valueAtNode: aGolapNode) < 0 ifTrue: [
			^ self decliningColor ].
		(model valueAtNode: aGolapNode) > 0 ifTrue: [
			^ self growingColor ] ].
	^ self normalColorFor: aGolapNode
]

{ #category : 'accessing' }
Golap >> comment [

	^ commentText text
]

{ #category : 'accessing' }
Golap >> comment: aString [

	commentText text: aString
]

{ #category : 'operations' }
Golap >> copyAllFromQueryViewTree [
	Clipboard
		clipboardText: (STONJSON toString: queryViewTree roots asDictionary)
]

{ #category : 'operations' }
Golap >> copyFromQueryViewTree [
	queryViewTree selectedItem
		ifNotNil:
			[ :assoc | Clipboard clipboardText: (STONJSON toString: assoc value) ]
		ifNil: [ Clipboard
				clipboardText: (STONJSON toString: queryViewTree roots asDictionary) ]
]

{ #category : 'snapshot' }
Golap >> createTemporarySnapshotDirectory [

	^ snapshotBaseName ifNotNil: [
		  | ref |
		  ref := (self golapDirectory / self temporaryDirectoryName
		          /
			          (snapshotBaseName , '--' , DateAndTime now printString
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

{ #category : 'accessing-colors' }
Golap >> decliningColor [
	^ colorsAppearancePresenter decliningColor
]

{ #category : 'accessing-dimensions' }
Golap >> dimensionAt: aString [
	^ dimensions at: aString ifAbsent: [ nil ]
]

{ #category : 'accessing-dimensions' }
Golap >> dimensionsDo: aBlock [
	dimensions do: aBlock
]

{ #category : 'snapshot' }
Golap >> disableSnapshotWhile: aBlock [

	| oldSnapshotEnabled |
	oldSnapshotEnabled := snapshotEnabled.
	snapshotEnabled := false.
	aBlock ensure: [ snapshotEnabled := oldSnapshotEnabled ]
]

{ #category : 'operations' }
Golap >> dumpToFile [
	"UIManager default
		informUserDuring: [ :progress | 
			(UIManager default
				chooseForSaveFileReference: 'Save gOLAP data'
				extensions: #('csv')
				path: GolapModel coocurrenceDataDirectory)
				ifNotNil: [ :ref | 
					ref
						writeStreamDo:
							[ :writeStream | self writeCSVOn: writeStream progressBlock: [ :v | progress value: v ] ] ] ]"

	self notYetImplemented
]

{ #category : 'accessing' }
Golap >> edgeEvaluator: aGolapEdgeEvaluator [

	edgesAppearancePresenter selectEdgeEvaluator: aGolapEdgeEvaluator
]

{ #category : 'accessing' }
Golap >> edgeEvaluators: aCollectionOfGolapEdgeEvaluator [

	edgesAppearancePresenter edgeEvaluators:
		aCollectionOfGolapEdgeEvaluator
]

{ #category : 'accessing' }
Golap >> edgeScale [
	^ edgesAppearancePresenter edgeScale
]

{ #category : 'accessing' }
Golap >> edgeScale: aNumber [
	edgesAppearancePresenter edgeScale: aNumber
]

{ #category : 'accessing-renderer' }
Golap >> elaborationRenderer [
	^ elaborationRenderer
		ifNil: [ elaborationRenderer := GolapElaborationRenderer on: self ]
]

{ #category : 'operations-photoimages' }
Golap >> ensurePhotoimageRetrievingProcess [

	(photoImageRetrievingProcess isNil or: [ 
		 photoImageRetrievingProcess isTerminating ]) ifTrue: [ 
		self startPhotoimageRetrievingProcess ]
]

{ #category : 'accessing' }
Golap >> font [
	^ font ifNil: [ font := TextStyle defaultFont ]
]

{ #category : 'accessing' }
Golap >> font: aFont [
	self updateGlobalImageAfter: [ font := aFont ]
]

{ #category : 'accessing-colors' }
Golap >> freshColor [
	^ colorsAppearancePresenter freshColor
]

{ #category : 'operations' }
Golap >> friendClusteredLayout [

	self overviewRenderer friendClusteredLayouter.
	self updateGlobalImageAfter: [  ] layout: true
]

{ #category : 'accessing' }
Golap >> friendsEdges [
	| num |
	model ifNil: [ ^ Array new ].
	num := edgesAppearancePresenter numFriends.
	^ model friendsEdges: num
]

{ #category : 'menu' }
Golap >> globalImageMenu: aGolapNode [

	| menu |
	menu := self newMenu.
	menu addGroup: [ :group |
		aGolapNode ifNotNil: [
			(self includesSelection: aGolapNode)
				ifTrue: [
					group addItem: [ :item |
						item
							name: 'Unselect';
							action: [ self toggleSelection: aGolapNode ] ] ]
				ifFalse: [
					group addItem: [ :item |
						item
							name: 'Select';
							action: [ self toggleSelection: aGolapNode ] ] ] ].
		self selections ifNotEmpty: [
			group addItem: [ :item |
				item
					name: 'Unselect all';
					action: [ self unselectAll ] ] ] ].
	menu addGroup: [ :group |
		aGolapNode ifNotNil: [
			(itemList markMenu: aGolapNode) ifNotNil: [ :submenu |
				group addItem: [ :item |
					item
						name: 'Mark';
						subMenu: submenu ] ].
			(itemList unmarkMenu: aGolapNode) ifNotNil: [ :submenu |
				group addItem: [ :item |
					item
						name: 'Unmark';
						subMenu: submenu ] ] ].
		self selections ifNotEmpty: [
			group
				addItem: [ :item |
					item
						name: 'Mark selections';
						subMenu: itemList markSelectionsMenu ];
				addItem: [ :item |
					item
						name: 'Unmark selections';
						subMenu: itemList unmarkSelectionsMenu ] ] ].
	aGolapNode ifNotNil: [
		rendererSelector = #overviewRenderer ifTrue: [
			menu addGroup: [ :group |
				(self renderer isReferenceNode: aGolapNode)
					ifTrue: [
						group addItem: [ :item |
							item
								name: 'remove from reference';
								action: [ self removeReferenceNode: aGolapNode ] ] ]
					ifFalse: [
						(self renderer isLockedNode: aGolapNode)
							ifTrue: [
								group
									addItem: [ :item |
										item
											name: 'move';
											action: [ self moveNode: aGolapNode ] ];
									addItem: [ :item |
										item
											name: 'be auto layouted';
											action: [ self unlockNode: aGolapNode ] ];
									addItem: [ :item |
										item
											name: 'add to reference';
											action: [
												self
													unlockNode: aGolapNode;
													addReferenceNode: aGolapNode ] ] ]
							ifFalse: [
								group
									addItem: [ :item |
										item
											name: 'add to reference';
											action: [ self addReferenceNode: aGolapNode ] ];
									addItem: [ :item |
										item
											name: 'be manual layouted';
											action: [
												self
													lockNode: aGolapNode;
													moveNode: aGolapNode ] ] ] ] ] ].
		menu
			addGroup: [ :group |
				(self includesPin: aGolapNode)
					ifTrue: [
						group addItem: [ :item |
								item
									name: 'Unpin';
									action: [ self togglePin: aGolapNode ] ] ]
					ifFalse: [
						group addItem: [ :item |
							item
								name: 'Pin';
								action: [ self togglePin: aGolapNode ] ] ] ];
			addGroup: [ :group |
				group addItem: [ :item |
					item
						name: 'Show info';
						action: [ itemView node: aGolapNode ] ] ] ].
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

{ #category : 'operations' }
Golap >> globalImageMouseClick: anEvent [

	anEvent wasHandled: true.
	dragNode
		ifNil: [
			| target |
			target := self renderer nodeAtPoint:
				          anEvent position
				          - globalImagePane adapter widget position.
			anEvent yellowButtonChanged ifTrue: [
				^ (self globalImageMenu: target) openWithSpecAt: anEvent position ].
			target ifNotNil: [ self toggleSelection: target ] ]
		ifNotNil: [
			self renderer
				moveNode: dragNode
				to: anEvent position - globalImagePane adapter widget position.
			dragNode := nil.
			anEvent hand showTemporaryCursor: nil.
			self updateGlobalImage ]
]

{ #category : 'operations' }
Golap >> globalImageMouseMove: anEvent [

	anEvent anyButtonPressed ifFalse: [ ^ self ].
	anEvent wasHandled: true.
	self updateGlobalImageAfter: [ 
		self renderer moveImageOffset: anEvent endPoint - anEvent startPoint ]
]

{ #category : 'operations' }
Golap >> globalImageMouseWheel: anEvent [

	anEvent direction = Character arrowUp ifTrue: [ ^ self zoomIn ].
	anEvent direction = Character arrowDown ifTrue: [ ^ self zoomOut ]
]

{ #category : 'accessing-widgets' }
Golap >> globalImagePane [
	^ globalImagePane
]

{ #category : 'operations' }
Golap >> globalMapMouseClick: anEvent [

	anEvent wasHandled: true
]

{ #category : 'operations' }
Golap >> globalMapMouseMove: anEvent [

	anEvent anyButtonPressed ifFalse: [ ^ self ].
	anEvent wasHandled: true.
	self updateGlobalImageAfter: [ 
		self renderer moveMapOffset: anEvent startPoint - anEvent endPoint ]
]

{ #category : 'accessing-widgets' }
Golap >> globalMapPane [
	^ globalMapPane
]

{ #category : 'accessing-presets' }
Golap >> golapDirectory [

	^ self class golapDirectory
]

{ #category : 'layouts' }
Golap >> graphLayout [

	<spec>
	^ SpBoxLayout newHorizontal
		  add: (SpBoxLayout newVertical
				   add: globalMapPane height: 200;
				   add: (SpBoxLayout newHorizontal
						    add: zoomInButton width: 110;
						    add: resetZoomButton width: 80;
						    add: zoomOutButton width: 110)
				   height: self buttonHeight;
				   add: (SpBoxLayout newHorizontal
						    add: frontList width: 150;
						    add: baseList)
				   height: self buttonHeight;
				   add: appearanceNotebook height: 300;
				   add: (SpBoxLayout newHorizontal
						    add: overviewRendererButton;
						    add: elaborationRendererButton)
				   height: self buttonHeight;
				   add: (SpBoxLayout newHorizontal
						    add: layoutButton expand: true;
						    add: layoutChooseButton width: 20;
						    add: (SpBoxLayout newVertical
								     add: overridesYWithFrequencyCheckbox expand: false;
								     add: overridesYWithFrequencyOrderCheckbox expand: false)
						    width: 100)
				   expand: false;
				   add: 'コメント' expand: false;
				   add: commentText;
				   yourself)
		  width: 350;
		  add: globalImagePane;
		  yourself
]

{ #category : 'accessing-colors' }
Golap >> growingColor [
	^ colorsAppearancePresenter growingColor
]

{ #category : 'menu' }
Golap >> iconForCircleColor: aColor [

	^ itemList iconForCircleColor: aColor
]

{ #category : 'private' }
Golap >> ifNotActive: aBlock [

	adapter ifNil: [ ^ aBlock value ].
	adapter widget ifNil: [ ^ aBlock value ].
	adapter widget world ifNil: [ ^ aBlock value ]
]

{ #category : 'snapshot' }
Golap >> ifSnapshotEnabled: aBlock [

	snapshotEnabled = true ifTrue: aBlock
]

{ #category : 'accessing' }
Golap >> imageRepositoryUrl: aString [

	productInfoRetriever imageRepositoryUrl: aString
]

{ #category : 'accessing-selection' }
Golap >> includesPin: aGolapNode [

	^ pins includes: aGolapNode id
]

{ #category : 'accessing-selection' }
Golap >> includesSelection: aGolapNode [

	^ selections contains: [ :id | aGolapNode includesId: id ]
]

{ #category : 'initialization' }
Golap >> initialize [

	super initialize.
	pins := Set new.
	selections := Set new.
	dimensions := OrderedDictionary new.
	merges := OrderedCollection new.
	rendererSelector := #overviewRenderer.
	snapshotEnabled := true.
	lastZoomTimestamp := DateAndTime now.
	drawingSemaphore := Semaphore forMutualExclusion.
	snapshotBaseName := ''
]

{ #category : 'initialization' }
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
		             display: [ :string |
			             string isSymbol
				             ifTrue: [ self pseudoDimensionNameAt: string ]
				             ifFalse: [ string asString ] ];
		             displayIcon: [ :string |
			             string isSymbol
				             ifTrue: [ self pseudoDimensionIconAt: string ]
				             ifFalse: [ nil ] ];
		             whenSelectedItemChangedDo: [ :front |
			             front isSymbol
				             ifTrue: [ self perform: front ]
				             ifFalse: [
					             baseList
						             items: (dimensions ifNil: [ #(  ) ] ifNotNil: [
									              dimensions keys asArray collect: [ :back |
											              front = back
												              ifTrue: [ String new ]
												              ifFalse: [ back ] ] ]);
						             selectItem: String new ] ];
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
				                       title: 'アイテム';
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
	layoutChooseButton := self newButton
		                      icon: (self iconNamed: #arrowDown);
		                      action: [
			                      self chooseLayouterMenu openWithSpecAtPointer ];
		                      yourself.
	overridesYWithFrequencyCheckbox := self newCheckBox
		                                   label: 'Y=freq';
		                                   labelOnRight;
		                                   state: false;
		                                   whenChangedDo: [
			                                   overridesYWithFrequencyCheckbox
				                                   state ifTrue: [
					                                   overridesYWithFrequencyOrderCheckbox
						                                   state: false ].
			                                   self
				                                   updateGlobalImageAfter: [  ]
				                                   layout: true ].
	overridesYWithFrequencyOrderCheckbox := self newCheckBox
		                                        label: 'Y=freq order';
		                                        labelOnRight;
		                                        state: false;
		                                        whenChangedDo: [
			                                        overridesYWithFrequencyOrderCheckbox
				                                        state ifTrue: [
					                                        overridesYWithFrequencyCheckbox
						                                        state: false ].
			                                        self
				                                        updateGlobalImageAfter: [
					                                         ]
				                                        layout: true ].
	commentText := self newText.
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
	edgeList := self newGolapEdgeList.
	itemNotebook := self newNotebook
		                addPage: (self newNotebookPage
				                 title: 'アイテムリスト';
				                 presenterProvider: [ itemList ];
				                 yourself);
		                addPage: (self newNotebookPage
				                 title: 'アイテム情報';
				                 presenterProvider: [ itemView ];
				                 yourself);
		                addPage: (self newNotebookPage
				                 title: '隣接アイテム';
				                 presenterProvider: [ edgeList ];
				                 yourself);
		                yourself.

	dandelionPresenter := self instantiate:
		                      (GolapDandelionChartPresenter new golap: self).
	hedgePresenter := self instantiate:
		                  (GolapHedgeChartPresenter new golap: self).
	viewsNotebook := self newNotebook
		                 addPageTitle: 'グラフ' provider: [
			                 SpPresenter new
				                 layout: self graphLayout;
				                 yourself ];
		                 addPageTitle: 'たんぽぽ図'
		                 provider: [ dandelionPresenter ];
		                 addPageTitle: '生垣図' provider: [ hedgePresenter ];
		                 whenSelectedPageChangedDo: [ :page |
			                 page activePresenter ifNotNil: [ :p |
				                 (p respondsTo: #updateTree) ifTrue: [
					                 p updateTree ] ] ];
		                 yourself.

	self whenBuiltDo: [ :w |
		| f |
		f := TextStyle defaultFont.
		w widget allMorphsDo: [ :m |
			(m respondsTo: #font:) ifTrue: [ m font: f ] ] ]
]

{ #category : 'initialization' }
Golap >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self title;
		initialExtent: World extent.
	aWindowPresenter whenClosedDo: [ self saveQueryRecord ]
]

{ #category : 'snapshot' }
Golap >> isTemporarySnapshot [

	^ self snapshotDirectory isNil or: [
		  self snapshotDirectory parent basename
		  = self temporaryDirectoryName ]
]

{ #category : 'accessing' }
Golap >> itemFieldQuerySpec: aDictionary [

	productInfoRetriever itemFieldQuerySpec: aDictionary
]

{ #category : 'accessing-widgets' }
Golap >> itemView [
	^ itemView
]

{ #category : 'accessing' }
Golap >> itemViewUrl: aString [

	productInfoRetriever golapServerUrl: aString
]

{ #category : 'menu' }
Golap >> lockNode: aGolapNode [

	self renderer lockNode: aGolapNode
]

{ #category : 'accessing-markers' }
Golap >> markedNodes [

	^ itemList markedNodes
]

{ #category : 'accessing-markers' }
Golap >> markersAndNodesDo: aBlock [

	itemList markersAndNodesDo: aBlock
]

{ #category : 'operations-photoimages' }
Golap >> maxPhotoimageRetrievalProcesses [

	^ 3
]

{ #category : 'private' }
Golap >> maxScale [
	^ 50.0
]

{ #category : 'menu' }
Golap >> mergeMenu [

	| menu |
	menu := self newMenu.
	menu addGroup: [ :group | 
		selections size > 1 ifTrue: [ 
			group addItem: [ :item | 
				item
					name: 'selections';
					action: [ self mergeSelectedNodes ] ] ].
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
							(self mergeNodes: ids copy) ifNotNil: [ :newId | 
									itemList markerDropList items do: [ :item | 
											item key = color ifTrue: [ item value: item value, ',',newId ] ].
									(itemList markers at: color) add: newId.
									itemList currentMarker: color.
									itemList updateNodeList ] ] ] ] ] ].
	^ menu
]

{ #category : 'merging' }
Golap >> mergeNodes: aCollectionOfIds [

	aCollectionOfIds size < 2 ifTrue: [ ^ nil ].
	^ model ifNotNil: [ 
		  (UIManager default
			   request: '統合したノード名'
			   initialAnswer: ''
			   title: 'ノードの統合') ifNotNil: [ :nodeName | 
			  (model nodes includesKey: nodeName)
				  ifTrue: [ 
					  UIManager default alert: '名前が重複しています'.
					  nil ]
				  ifFalse: [ 
					  merges add: nodeName -> aCollectionOfIds copy.
					  self updateModel.
					  itemList updateNodeList.
					  nodeName ] ] ]
]

{ #category : 'merging' }
Golap >> mergeSelectedNodes [

	^ self selections
		  ifNotEmpty: [ :nodes |
			  (self mergeNodes: (nodes collect: #id)) ifNotNil: [ :newId |
				  self select: (model nodeAt: newId) ] ]
		  ifEmpty: [ nil ]
]

{ #category : 'accessing' }
Golap >> minFrequency [

	^ itemsAppearancePresenter minFrequency
]

{ #category : 'private' }
Golap >> minScale [
	^ 0.9
]

{ #category : 'accessing' }
Golap >> model [
	^ model
]

{ #category : 'accessing' }
Golap >> model: aGolapModel [
	self model: aGolapModel forceUpdate: true
]

{ #category : 'accessing' }
Golap >> model: aGolapModel forceUpdate: aBoolean [

	(aBoolean == false and: [ aGolapModel == model ]) ifTrue: [ ^ self ].
	(model notNil and: [ aGolapModel notNil ]) ifTrue: [
		model nodes keysAndValuesDo: [ :id :v1 |
			(aGolapModel nodeAt: id ifAbsent: [ nil ]) ifNotNil: [ :v2 |
				v2
					x: v1 x;
					y: v1 y ] ] ].
	self
		updateGlobalImageAfter: [
			model := aGolapModel.
			model flushFriendsEdges.
			self overviewRenderer layouter model: model.
			self unselectAll.
			model ifNotNil: [
				itemsAppearancePresenter updateMinMaxFrequency.
				edgesAppearancePresenter updateModel: model.
				itemList updateNodeList ] ]
		layout: (aGolapModel nodes anySatisfy: [ :node |
				 node x isNil or: [ node y isNil ] ]).
	self announceGolapModelUpdated
]

{ #category : 'menu' }
Golap >> moveNode: aGolapNode [

	dragNode := aGolapNode.
	self withAdapterDo: [ :a |
		a widgetDo: [ :w |
			w activeHand showTemporaryCursor: Cursor crossHair ] ]
]

{ #category : 'accessing-colors' }
Golap >> negativePolishColor [
	^ colorsAppearancePresenter negativePolishColor
]

{ #category : 'instance creation' }
Golap >> newGolapEdgeList [

	^ (self instantiate: GolapEdgeList)
		  golap: self;
		  yourself
]

{ #category : 'instance creation' }
Golap >> newGolapItemList [

	^ (self instantiate: GolapItemList)
		  golap: self;
		  yourself
]

{ #category : 'instance creation' }
Golap >> newGolapItemView [

	^ (self instantiate: GolapItemView)
		  golap: self;
		  yourself
]

{ #category : 'accessing' }
Golap >> nodeEvaluator: aGolapNodeEvaluator [

	edgesAppearancePresenter selectNodeEvaluator: aGolapNodeEvaluator
]

{ #category : 'accessing' }
Golap >> nodeEvaluators: aCollectionOfGolapNodeEvaluator [

	edgesAppearancePresenter nodeEvaluators:
		aCollectionOfGolapNodeEvaluator
]

{ #category : 'accessing' }
Golap >> nodes [
	^ model ifNil: [ #() ] ifNotNil: [ model nodes values ]
]

{ #category : 'enumerating' }
Golap >> nodesDo: aBlock [
	model ifNotNil: [ model nodes valuesDo: aBlock ]
]

{ #category : 'accessing-colors' }
Golap >> normalColor [
	^ colorsAppearancePresenter normalColor
]

{ #category : 'accessing-colors' }
Golap >> normalColorFor: aGolapNode [
	^ colorsAppearancePresenter normalColorFor: aGolapNode
]

{ #category : 'accessing' }
Golap >> numFriends [
	edgesAppearancePresenter numFriends
]

{ #category : 'accessing' }
Golap >> numFriends: anInteger [
	edgesAppearancePresenter numFriends: anInteger
]

{ #category : 'accessing' }
Golap >> numLabels [
	^ itemsAppearancePresenter numLabels
]

{ #category : 'instance creation' }
Golap >> open [

	| window |
	window := super open.
	self startPhotoimageRetrievingProcess.
	^ window
]

{ #category : 'operations' }
Golap >> openPresetQueryDialog [

	| presetQueries queryList |
	presetQueries := self readPresetQueries.
	queryList := SpEditableListPresenter new.
	queryList
		title: 'アイテム名フィルタ';
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
		openModal
]

{ #category : 'operations' }
Golap >> openSunburst [

	(GolapDandelionChartPresenter new
		 golap: self;
		 yourself) open maximize
]

{ #category : 'accessing-widgets' }
Golap >> overridesYWithFrequencyCheckbox [
	^ overridesYWithFrequencyCheckbox
]

{ #category : 'accessing-widgets' }
Golap >> overridesYWithFrequencyOrderCheckbox [
	^ overridesYWithFrequencyOrderCheckbox
]

{ #category : 'accessing-renderer' }
Golap >> overviewRenderer [
	^ overviewRenderer
		ifNil: [ overviewRenderer := GolapOverviewRenderer on: self ]
]

{ #category : 'operations-photoimages' }
Golap >> photoimageSize [

	^ 64
]

{ #category : 'accessing-colors' }
Golap >> pinColor [
	^ Color red
]

{ #category : 'enumerating' }
Golap >> pinsDo: aBlock [
	model
		ifNotNil: [ pins
				do:
					[ :id | (model nodeAt: id ifAbsent: [  ]) ifNotNil: aBlock ] ]
]

{ #category : 'accessing-dimensions' }
Golap >> playIcon [

	^ self iconNamed: #smallDoIt
]

{ #category : 'accessing-colors' }
Golap >> positivePolishColor [
	^ colorsAppearancePresenter positivePolishColor
]

{ #category : 'accessing-presets' }
Golap >> presetQueryFile [
	^ self golapDirectory / 'presetQueries.json'
]

{ #category : 'accessing' }
Golap >> productInfoRetriever [

	^ productInfoRetriever
]

{ #category : 'accessing' }
Golap >> productInfoRetriever: aGolapProductInfoRetriever [

	productInfoRetriever := aGolapProductInfoRetriever.
	itemsAppearancePresenter updatePhotoimageRetrievers
]

{ #category : 'accessing-dimensions' }
Golap >> pseudoDimensionIconAt: aSymbol [

	aSymbol = #animateDimensions ifTrue: [ ^ self playIcon ].
	^ nil
]

{ #category : 'accessing-dimensions' }
Golap >> pseudoDimensionNameAt: aSymbol [

	aSymbol = #animateDimensions ifTrue: [ ^ '流す...' ].
	^ '-'
]

{ #category : 'accessing-dimensions' }
Golap >> pseudoDimensionNames [

	^ #( animateDimensions )
]

{ #category : 'accessing' }
Golap >> query [
	^ query
]

{ #category : 'accessing' }
Golap >> query: aDictionary [

	self setQuery: aDictionary
]

{ #category : 'accessing' }
Golap >> queryRecord [

	^ queryRecord
]

{ #category : 'accessing' }
Golap >> queryRecord: aGolapQueryRecord [

	queryRecord := aGolapQueryRecord
]

{ #category : 'menu' }
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

{ #category : 'private' }
Golap >> readDimensionFrom: aReadStream [

	[
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
	dimension := GolapModel fromServerDataframe: dataframe.
	edgesAppearancePresenter updateModel: dimension.
	self silentAddDimension: dimension named: name.
	[ aReadStream peekFor: Character lf ] whileTrue ]
		on: Error
		do: [ :ex |
			self delete.
			Processor activeProcess terminate ]
]

{ #category : 'accessing-presets' }
Golap >> readPresetQueries [
	[ self presetQueryFile ensureCreateFile
		readStreamDo: [ :stream | ^ (NeoJSONReader on: stream) next ] ]
		on: Error
		do: [ :ex | ^ Array new ]
]

{ #category : 'private' }
Golap >> regexFor: aString [
	| regex |
	regex := #('\' '.' '[' ']' '(' ')' '!' '+')
		inject: aString
		into: [ :p :special | p copyReplaceAll: special with: '\' , special ].
	^ ((regex copyReplaceAll: '*' with: '.*')
		copyReplaceAll: '?'
		with: '[ -~]+') asRegex
]

{ #category : 'initialization' }
Golap >> release [

	dimensions := nil.
	frontList := nil.
	baseList := nil.
	model := nil.
	overviewRenderer := nil.
	elaborationRenderer := nil.
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

{ #category : 'menu' }
Golap >> removeReferenceNode: aGolapNode [

	overviewRenderer removeReferenceNode: aGolapNode.
	self updateGlobalImage
]

{ #category : 'accessing-renderer' }
Golap >> renderer [
	^ self perform: rendererSelector
]

{ #category : 'accessing-renderer' }
Golap >> rendererSelector [

	^ rendererSelector
]

{ #category : 'operations' }
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

{ #category : 'private' }
Golap >> resetVisibleEdgeThresholds [
	edgesAppearancePresenter resetVisibleEdgeThresholds 
]

{ #category : 'operations' }
Golap >> resetZoom [
	self
		updateGlobalImageAfter: [ self renderer resetZoom]
]

{ #category : 'snapshot' }
Golap >> restoreColorsAppearance [

	| ref |
	ref := self snapshotDirectory / 'appearance-colors.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			colorsAppearancePresenter restore: stream ] ]
]

{ #category : 'snapshot' }
Golap >> restoreData [

	| ref |
	ref := self snapshotDirectory / 'data.json'.
	ref isFile ifTrue: [
		ref readStreamDo: [ :readStream |
			dimensions removeAll.
			(STONJSON fromStream: readStream) keysAndValuesDo: [ :name :json |
				dimensions at: name put: (GolapModel fromJSON: json) ] ].
		self updateDimensions ]
]

{ #category : 'snapshot' }
Golap >> restoreEdgesAppearance [

	| ref |
	ref := self snapshotDirectory / 'appearance-edges.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			edgesAppearancePresenter restore: stream ] ]
]

{ #category : 'snapshot' }
Golap >> restoreElaborationRenderer [

	| ref |
	ref := self snapshotDirectory / 'renderer-elaboration.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			self elaborationRenderer restore: stream ] ]
]

{ #category : 'snapshot' }
Golap >> restoreItemList [

	| ref |
	ref := self snapshotDirectory / 'item-list.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | itemList restore: stream ] ]
]

{ #category : 'snapshot' }
Golap >> restoreItemView [

	| ref |
	ref := self snapshotDirectory / 'item-view.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | itemView restore: stream ] ]
]

{ #category : 'snapshot' }
Golap >> restoreItemsAppearance [

	| ref |
	ref := self snapshotDirectory / 'appearance-items.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			itemsAppearancePresenter restore: stream ] ]
]

{ #category : 'snapshot' }
Golap >> restoreMerges [

	| ref |
	ref := self snapshotDirectory / 'merges.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			(NeoJSONReader on: stream) next ifNotNil: [ :json | 
				merges := json collect: [ :pair | pair first -> pair second ] ] ] ]
]

{ #category : 'snapshot' }
Golap >> restoreOverviewRenderer [

	| ref |
	ref := self snapshotDirectory / 'renderer-overview.json'.
	ref isFile ifTrue: [ 
		ref readStreamDo: [ :stream | 
			self overviewRenderer restore: stream ] ]
]

{ #category : 'snapshot' }
Golap >> restoreQuery [

	| ref |
	ref := self snapshotDirectory / 'query.json'.
	ref isFile ifTrue: [
		ref readStreamDo: [ :stream |
			(NeoJSONReader on: stream) next ifNotNil: [ :json |
				(json at: 'url' ifAbsent: [ nil ]) ifNotNil: [ :string |
					url := string asUrl ].
				(json at: 'query' ifAbsent: [ nil ]) ifNotNil: [ :dictionary |
					self setQuery: dictionary ].
				(json at: 'comment' ifAbsent: [ nil ]) ifNotNil: [ :comment |
					self comment: comment ] ] ] ]
]

{ #category : 'snapshot' }
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

{ #category : 'snapshot' }
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

{ #category : 'accessing-colors' }
Golap >> retreatingColor [
	^ colorsAppearancePresenter retreatingColor
]

{ #category : 'operations-photoimages' }
Golap >> retrievePhotoimage [

	rendererSelector = #overviewRenderer ifTrue: [ 
		self retrievePhotoimageOnOverviewRenderer ].
	rendererSelector = #elaborationRenderer ifTrue: [ 
		self retrievePhotoimageOnElaborationRenderer ]
]

{ #category : 'operations-photoimages' }
Golap >> retrievePhotoimageFor: aGolapNode [

	aGolapNode photoimage: false.
	[ retrievalProcessCount > self maxPhotoimageRetrievalProcesses ]
		whileTrue: [ 300 milliSecond wait ].
	retrievalProcessCount := retrievalProcessCount + 1.
	[
	productInfoRetriever ifNotNil: [
		[
		(productInfoRetriever photoimageFor: aGolapNode) ifNotNil: [ :image |
			aGolapNode photoimage:
				(image scaledToSize: self photoimageSize asPoint).
			self updateGlobalImageAfter: [  ] ] ] ensure: [
			retrievalProcessCount := retrievalProcessCount - 1 ] ] ] forkAt:
		Processor userBackgroundPriority - 5
]

{ #category : 'operations-photoimages' }
Golap >> retrievePhotoimageOnElaborationRenderer [

	[
	elaborationRenderer ifNotNil: [
		overviewRenderer nodesDo: [ :node |
			node basicPhotoimage ifNil: [ ^ self retrievePhotoimageFor: node ].
			Processor yield ] ] ]
		on: Error
		do: [ :ex |  ]
]

{ #category : 'operations-photoimages' }
Golap >> retrievePhotoimageOnOverviewRenderer [

	[
	overviewRenderer ifNotNil: [
		globalImagePane withAdapterDo: [ :a |
			a widgetDo: [ :w |
				| origin corner mouse minD minV |
				origin := overviewRenderer nodePointAtPoint:
					          (-10 @ -10 min: w extent // 10).
				corner := overviewRenderer nodePointAtPoint:
					          w extent + (10 @ 10 max: w extent // 10).
				mouse := overviewRenderer nodePointAtPoint:
					         w activeHand position - w position.
				minD := Float infinity.
				minV := nil.
				overviewRenderer reallyVisibleNodesDo: [ :node |
					node basicPhotoimage ifNil: [
						node x ifNotNil: [ :x |
							node y ifNotNil: [ :y |
								((x between: origin x and: corner x) and: [
									 y between: origin y and: corner y ]) ifTrue: [
									| d |
									d := (x - mouse x) squared + (y - mouse y) squared.
									d < minD ifTrue: [
										minD := d.
										minV := node ] ] ] ] ].
					Processor yield ].

				minV ifNotNil: [ ^ self retrievePhotoimageFor: minV ] ] ] ] ]
		on: Error
		do: [ :ex |  ]
]

{ #category : 'operations' }
Golap >> saveAsSVG [
	(UIManager default
		chooseForSaveFileReference: 'Save as a SVG file'
		extensions: #('svg')
		path: self golapDirectory)
		ifNotNil: [ :fileReference | 
			fileReference
				writeStreamDo: [ :stream | self renderer svg printWithPrologOn: stream ] ]
]

{ #category : 'operations' }
Golap >> saveFullImage [

	(UIManager default
		 chooseForSaveFileReference: 'Save as a PNG file'
		 extensions: #( 'png' )
		 path: self golapDirectory) ifNotNil: [ :fileReference | 
		fileReference binaryWriteStreamDo: [ :stream | 
			Cursor wait showWhile: [ 
				PNGReadWriter putForm: self renderer fullImage onStream: stream ] ] ]
]

{ #category : 'history' }
Golap >> saveQueryRecord [

	queryRecord ifNotNil: [
		globalImagePane image ifNotNil: [ :image |
			queryRecord thumbnail: (image scaledToSize: 256 @ 256) ].
		queryRecord comment:
			(commentText text asString trim ifEmpty: [ nil ]).
		queryRecord hideSave ]
]

{ #category : 'snapshot' }
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

{ #category : 'accessing-selection' }
Golap >> select: aGolapNode [

	aGolapNode idDo: [ :id | selections add: id ].
	selectedEdges := nil.
	self showItemView: aGolapNode.
	self updateSelection
]

{ #category : 'accessing-selection' }
Golap >> selectAll: aCollectionOfGolapNode [

	aCollectionOfGolapNode do: [ :node |
		node idDo: [ :id | selections add: id ] ].
	selectedEdges := nil.
	self showItemView: aCollectionOfGolapNode anyOne.
	self updateSelection
]

{ #category : 'accessing-dimensions' }
Golap >> selectedBaseDimension [
	^ dimensions at: baseList selectedItem ifAbsent: [ nil ]
]

{ #category : 'accessing' }
Golap >> selectedEdges [
	^ selectedEdges
		ifNil: [ | edges |
			edges := IdentitySet new: selections size.
			self selections do: [ :v | v edgesDo: [ :e | edges add: e ] ].
			selectedEdges := edges asArray ]
]

{ #category : 'accessing-dimensions' }
Golap >> selectedFrontDimension [
	^ dimensions at: frontList selectedItem ifAbsent: [ nil ]
]

{ #category : 'accessing-dimensions' }
Golap >> selectedModel [

	^ (self selectedFrontDimension ifNil: [ nil ] ifNotNil: [ :front | 
		   self selectedBaseDimension ifNil: [ front ] ifNotNil: [ :base | 
			   self
				   applyMergesToModel: front;
				   applyMergesToModel: base.
			   front - base ] ]) ifNotNil: [ :m | self applyMergesToModel: m ]
]

{ #category : 'enumerating' }
Golap >> selectedNodesDo: aBlock [

	model nodesDo: [ :node |
		(selections anySatisfy: [ :id | node includesId: id ]) ifTrue: [
			aBlock value: node ] ]
]

{ #category : 'accessing-colors' }
Golap >> selectionColor [
	^ colorsAppearancePresenter selectionColor
]

{ #category : 'accessing-selection' }
Golap >> selections [
	^ Array
		streamContents: [ :stream | 
			model
				nodesDo: [ :v | 
					(selections anySatisfy: [ :id | v includesId: id ])
						ifTrue: [ stream nextPut: v ] ] ]
]

{ #category : 'accessing-selection' }
Golap >> selections: aCollectionOfGolapNode [

	| newSelections |
	newSelections := Set new: aCollectionOfGolapNode size.
	aCollectionOfGolapNode do: [ :v |
		v idDo: [ :id | newSelections add: id ] ].
	selections = newSelections ifFalse: [
		selections := newSelections.
		selectedEdges := nil.
		self showItemView: aCollectionOfGolapNode last.
		self updateSelection ]
]

{ #category : 'accessing-renderer' }
Golap >> setElaborationRenderer [

	self updateGlobalImageAfter: [ 
		rendererSelector := #elaborationRenderer.
		elaborationRendererButton state: true.
		overviewRendererButton state: false ]
]

{ #category : 'accessing-renderer' }
Golap >> setOverviewRenderer [

	self
		updateGlobalImageAfter: [ 
			rendererSelector := #overviewRenderer.
			elaborationRendererButton state: false.
			overviewRendererButton state: true ]
		layout: (self nodes anySatisfy: [ :v | v asPoint isNil ])
]

{ #category : 'accessing' }
Golap >> setQuery: aDictionary [

	query := aDictionary.

	queryViewTree roots:
		(query keys asSortedCollection collect: [ :key |
			 key -> (query at: key) ]).
	productInfoRetriever ifNotNil: [
		productInfoRetriever query: aDictionary ]
]

{ #category : 'accessing-selection' }
Golap >> setSelections: aCollectionOfString [

	| newSelections |
	newSelections := aCollectionOfString asSet.
	selections = newSelections ifFalse: [
		selections := newSelections.
		selectedEdges := nil.
		itemList selectedItem ifNotNil: [ :item |
			self showItemView: (model nodeAt: item) ].
		self updateSelection ]
]

{ #category : 'operations' }
Golap >> showItemView: aGolapNode [
	aGolapNode ifNotNil: [ itemView node: aGolapNode ]
]

{ #category : 'accessing' }
Golap >> showsConnectedNodes [
	^ itemsAppearancePresenter showsConnectedNodes
]

{ #category : 'accessing' }
Golap >> showsHiddenConnectionNodes [
	^ itemsAppearancePresenter showsHiddenConnectionNodes
]

{ #category : 'accessing' }
Golap >> showsIsolatedNodes [
	^ itemsAppearancePresenter showsIsolatedNodes
]

{ #category : 'accessing-dimensions' }
Golap >> silentAddDimension: aGolapOverviewModel named: aString [
	dimensions at: aString put: aGolapOverviewModel.
	^ aGolapOverviewModel
]

{ #category : 'private' }
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

{ #category : 'snapshot' }
Golap >> snapshotBaseDirectory [

	^ (self golapDirectory / self snapshotBaseDirectoryName)
		  ensureCreateDirectory;
		  yourself
]

{ #category : 'snapshot' }
Golap >> snapshotBaseDirectoryName [

	^ 'snapshots'
]

{ #category : 'accessing' }
Golap >> snapshotBaseName [

	^ snapshotBaseName
]

{ #category : 'accessing' }
Golap >> snapshotBaseName: aString [

	snapshotBaseName := aString
]

{ #category : 'snapshot' }
Golap >> snapshotColorsAppearance: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'appearance-colors.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : 'snapshot' }
Golap >> snapshotData [

	self snapshotDirectory ifNotNil: [ :baseDir |
		(baseDir / 'data.json')
			ensureDelete;
			writeStreamDo: [ :writeStream |
				STONJSON
					put: (dimensions associations collect: [ :assoc |
								 assoc key -> assoc value asJSON ]) asOrderedDictionary
					onStreamPretty: writeStream ] ]
]

{ #category : 'snapshot' }
Golap >> snapshotData: aReadStream do: aBlock [

	self snapshotQuery.
	(aReadStream notNil and: [ aReadStream isString not ])
		ifTrue: [
			aBlock value: aReadStream.
			self snapshotData ]
		ifFalse: [ aBlock value: nil ]
]

{ #category : 'snapshot' }
Golap >> snapshotDirectory [

	^ (snapshotDirectory ifNil: [ 
		   snapshotDirectory := self createTemporarySnapshotDirectory ifNil: [ ^ nil ] ])
		  ensureCreateDirectory
]

{ #category : 'snapshot' }
Golap >> snapshotEdgesAppearance: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'appearance-edges.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : 'snapshot' }
Golap >> snapshotElaborationRenderer: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'renderer-elaboration.json') ensureDelete 
				writeStreamDo: [ :writeStream | aBlock value: writeStream ] ] ]
]

{ #category : 'snapshot' }
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

{ #category : 'snapshot' }
Golap >> snapshotItemList: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'item-list.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : 'snapshot' }
Golap >> snapshotItemView: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'item-view.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : 'snapshot' }
Golap >> snapshotItemsAppearance: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'appearance-items.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : 'snapshot' }
Golap >> snapshotMerges [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'merges.json') ensureDelete writeStreamDo: [ :stream | 
				(NeoJSONWriter on: stream) nextPut: (merges collect: [ :assoc | 
						 { 
							 assoc key.
							 assoc value } ]) ] ] ]
]

{ #category : 'snapshot' }
Golap >> snapshotOverviewRenderer: aBlock [

	self ifSnapshotEnabled: [ 
		self snapshotDirectory ifNotNil: [ :baseDir | 
			(baseDir / 'renderer-overview.json') ensureDelete writeStreamDo: [ 
				:writeStream | aBlock value: writeStream ] ] ]
]

{ #category : 'snapshot' }
Golap >> snapshotQuery [

	self ifSnapshotEnabled: [
		self snapshotDirectory ifNotNil: [ :baseDir |
			| queryJson |
			queryJson := Dictionary new.
			url ifNotNil: [ queryJson at: 'url' put: url printString ].
			query ifNotNil: [ queryJson at: 'query' put: query ].
			self comment ifNotNil: [ :comment |
				queryJson at: 'comment' put: comment ].
			(baseDir / 'query.json') ensureDelete writeStreamDo: [ :stream |
				(NeoJSONWriter on: stream) nextPut: queryJson ] ] ]
]

{ #category : 'snapshot' }
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

{ #category : 'operations' }
Golap >> springLayout [

	self overviewRenderer springLayouter.
	self updateGlobalImageAfter: [  ] layout: true
]

{ #category : 'operations-photoimages' }
Golap >> startPhotoimageRetrievingProcess [

	self stopPhotoimageRetrievingProcess.
	(productInfoRetriever isNil or: [
		 productInfoRetriever hasPhotoImage not ]) ifTrue: [ ^ self ].
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

{ #category : 'operations-photoimages' }
Golap >> stopPhotoimageRetrievingProcess [

	photoImageRetrievingProcess ifNotNil: [ 
		photoImageRetrievingProcess terminate.
		photoImageRetrievingProcess := nil ]
]

{ #category : 'snapshot' }
Golap >> temporaryDirectoryName [

	^ 'temporary'
]

{ #category : 'accessing' }
Golap >> title [

	^ (self basicSnapshotDirectory notNil and: [ 
		   self isTemporarySnapshot not ])
		  ifTrue: [ self snapshotDirectory basename ]
		  ifFalse: [ 'gOLAP' ]
]

{ #category : 'accessing-selection' }
Golap >> togglePin: aGolapNode [

	self updateGlobalImageAfter: [
		| id |
		id := aGolapNode id.
		(pins includes: id)
			ifTrue: [ pins remove: id ]
			ifFalse: [ pins add: id ] ]
]

{ #category : 'accessing-selection' }
Golap >> toggleSelection: aGolapNode [
	self
		updateGlobalImageAfter: [ (self includesSelection: aGolapNode)
				ifTrue: [ self unselect: aGolapNode ]
				ifFalse: [ self select: aGolapNode ] ]
]

{ #category : 'menu' }
Golap >> unlockNode: aGolapNode [

	self overviewRenderer unlockNode: aGolapNode
]

{ #category : 'menu' }
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
								action: [ self unmergeNode: assoc key ] ] ] ].
	^ menu
]

{ #category : 'merging' }
Golap >> unmergeNode: aString [

	merges removeAllSuchThat: [ :assoc | assoc key = aString ].
	self updateModel.
	itemList updateNodeList
]

{ #category : 'accessing-selection' }
Golap >> unselect: aGolapNode [

	aGolapNode idDo: [ :id | selections remove: id ifAbsent: [  ] ].
	selectedEdges := nil.
	self updateSelection
]

{ #category : 'accessing-selection' }
Golap >> unselectAll [

	selections removeAll.
	selectedEdges := nil.
	self updateSelection
]

{ #category : 'accessing-selection' }
Golap >> unselectAll: aCollectionOfGolapNode [

	aCollectionOfGolapNode do: [ :node |
		node idDo: [ :id | selections remove: id ifAbsent: [  ] ] ].
	selectedEdges := nil.
	self updateSelection
]

{ #category : 'accessing-dimensions' }
Golap >> updateDimensions [

	frontList
		items: dimensions keys , self pseudoDimensionNames;
		selectIndex: 1
]

{ #category : 'drawing' }
Golap >> updateGlobalImage [

	drawingSemaphore critical: [
		| imageAndMap |
		imageAndMap := self renderer globalImageAndMap.
		globalImagePane image: imageAndMap first.
		globalMapPane image: imageAndMap second ].
	self ensurePhotoimageRetrievingProcess.
	self announcer announce: GolapViewUpdated new
]

{ #category : 'drawing' }
Golap >> updateGlobalImageAfter: aBlock [

	^ self updateGlobalImageAfter: aBlock layout: false
]

{ #category : 'drawing' }
Golap >> updateGlobalImageAfter: aBlock layout: aBoolean [

	| sender |
	sender := thisContext sender.
	aBlock ensure: [
		(self window notNil and: [ self window isClosed not ]) ifTrue: [
			[ sender notNil ] whileTrue: [
				sender selector = #updateGlobalImageAfter:layout: ifTrue: [
					^ self ].
				sender := sender sender ].
			aBoolean = true ifTrue: [ self basicLayout ].
			self updateGlobalImage ] ]
]

{ #category : 'operations' }
Golap >> updateItemView [
	self
		showItemView:
			(model
				nodeAt: itemList selectedItem
				ifAbsent: [ ^ self ])
]

{ #category : 'operations' }
Golap >> updateModel [
	self model: self selectedModel.
	itemList modelChanged.
	edgeList modelChanged
]

{ #category : 'private' }
Golap >> updateQuery [
	itemList updateNodeList
]

{ #category : 'accessing-selection' }
Golap >> updateSelection [

	self updateGlobalImageAfter: [
		itemList ifNotNil: [ itemList selectedItems: selections ].
		edgeList ifNotNil: [ edgeList updateNodeDropList ] ].
	self announcer announce: GolapViewUpdated new
]

{ #category : 'accessing' }
Golap >> url [
	^ url
]

{ #category : 'accessing' }
Golap >> url: aZnUrl [

	url := aZnUrl asUrl.
	snapshotBaseName := url host asString
]

{ #category : 'accessing-widgets' }
Golap >> visibleEdgeMaxPercentile [
	^ edgesAppearancePresenter ifNotNil: #visibleEdgeMaxPercentile
]

{ #category : 'accessing-widgets' }
Golap >> visibleEdgeMinPercentile [
	^ edgesAppearancePresenter ifNotNil: #visibleEdgeMinPercentile
]

{ #category : 'accessing' }
Golap >> visibleEdges [

	^ edgesAppearancePresenter visibleEdges
]

{ #category : 'accessing-presets' }
Golap >> writePresetQueries: anArrayOfString [
	self presetQueryFile ensureDelete
		writeStreamDo: [ :stream | ^ (NeoJSONWriter on: stream) nextPut: anArrayOfString ]
]

{ #category : 'operations' }
Golap >> zoomIn [

	(lastZoomTimestamp notNil and: [ 
		 DateAndTime now - lastZoomTimestamp < 0.1 seconds ]) ifTrue: [ 
		^ self ].
	lastZoomTimestamp := DateAndTime now.
	self updateGlobalImageAfter: [ self renderer zoomIn ]
]

{ #category : 'operations' }
Golap >> zoomInCenter [

	(lastZoomTimestamp notNil and: [ 
		 DateAndTime now - lastZoomTimestamp < 0.1 seconds ]) ifTrue: [ 
		^ self ].
	lastZoomTimestamp := DateAndTime now.
	self updateGlobalImageAfter: [ self renderer zoomInCenter ]
]

{ #category : 'operations' }
Golap >> zoomOut [

	(lastZoomTimestamp notNil and: [ 
		 DateAndTime now - lastZoomTimestamp < 0.1 seconds ]) ifTrue: [ 
		^ self ].
	lastZoomTimestamp := DateAndTime now.
	self updateGlobalImageAfter: [ self renderer zoomOut ]
]

{ #category : 'operations' }
Golap >> zoomOutCenter [

	(lastZoomTimestamp notNil and: [ 
		 DateAndTime now - lastZoomTimestamp < 0.1 seconds ]) ifTrue: [ 
		^ self ].
	lastZoomTimestamp := DateAndTime now.
	self updateGlobalImageAfter: [ self renderer zoomOutCenter ]
]
