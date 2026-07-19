Class {
	#name : 'Golap',
	#superclass : 'SpPresenter',
	#traits : 'TGolapSnapshotablePresenter',
	#classTraits : 'TGolapSnapshotablePresenter classTrait',
	#instVars : [
		'model',
		'queryRecord',
		'url',
		'query',
		'pins',
		'selections',
		'font',
		'itemView',
		'baseList',
		'dimensions',
		'merges',
		'frontList',
		'queryViewTree',
		'itemsAppearancePresenter',
		'authenticateBlock',
		'edgesAppearancePresenter',
		'colorsAppearancePresenter',
		'saveAsPngButton',
		'itemList',
		'itemNotebook',
		'saveAsSvgButton',
		'photoImageRetrievingProcess',
		'commentText',
		'dandelionPresenter',
		'hedgePresenter',
		'edgeList',
		'heatmapPresenter',
		'polishOverviewPresenter',
		'elaborationPresenter',
		'articulationPointOverviewPresenter',
		'itemInfoRetriever',
		'resendQueryButton',
		'visualizationNotebook',
		'imageCache',
		'leftPaneOpenCloseButton'
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

{ #category : 'utilities' }
Golap class >> deploy [

	<script>
	GolapMenubar reset.
	GolapNamedProject flushCurrent.
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
	PasteUpMorph shouldShowWorldMenu: false.
	MenubarMorph showMenubar: false.
	5 timesRepeat: [ Smalltalk garbageCollect ]
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

{ #category : 'accessing' }
Golap class >> golapDirectory [

	^ (FileLocator documents / 'gOLAP') ensureCreateDirectory
]

{ #category : 'menus' }
Golap class >> golapMenuOn: aBuilder [

	<worldMenu>
	<golapMenu>
	(aBuilder item: #Golap)
		label: 'gOLAP';
		order: 1;
		with: [
				(aBuilder item: #GolapServerMenu)
					label: 'サーバー';
					order: 50;
					with: [
							(aBuilder item: #GolapOpenServerFile)
								label: 'サーバファイルを開く...';
								iconName: #open;
								order: 60;
								target: self;
								selector: #openFile;
								help: 'サーバからのグラフデータを保存したファイルを選択して開きます' ].
				(aBuilder item: #GolapSettings)
					label: '設定...';
					parent: #Golap;
					order: 90;
					target: self;
					selector: #showSettingBrowser;
					help: '設定ウィンドウを開きます'.
				(aBuilder item: #GolapAbout)
					label: 'About...';
					parent: 'Golap';
					order: 99;
					target: self;
					selector: #openAboutDialog;
					help: 'gOLAPのロゴとバージョンを表示します' ]
]

{ #category : 'class initialization' }
Golap class >> initialize [

	SessionManager default registerUserClassNamed: self name
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

{ #category : 'utilities' }
Golap class >> openFile [

	<script: 'GolapOverview openFile'>
	| overview |
	overview := Golap new.
	overview open maximize.
	(UIManager default
		 chooseExistingFileReference: 'サーバからダウンロードしたファイルを選択してください。'
		 extensions: #( 'csv' )
		 path: self golapDirectory) in: [ :ref |
			(ref notNil and: [ ref isFile ])
				ifTrue: [
						ref readStreamDo: [ :readStream |
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
															overview blockUpdateModelWhile: [
																	| d |
																	d := 0.
																	[
																		bar value: readStream position.
																		readStream atEnd ] whileFalse: [
																			'ディメンジョン (' , (d := d + 1) asString , ') 読み込み中'.

																			overview readDimensionFrom: readStream ].
																	bar label: 'グラフ更新中'.
																	overview updateDimensions ].
															overview updateModel ] ] ] ] ]
				ifFalse: [ overview delete ] ].
	^ overview
]

{ #category : 'startup - shutdown' }
Golap class >> resume [

	[
		self sessionFile readStreamDo: [ :stream |
				(GolapJSON fromStream: stream) ifNotNil: [ :json |
						json
							at: 'session'
							ifPresent: [ :session |
							GolapPhantasmicProject fromJSON: session ] ] ] ]
		on: Exception
		do: [ :ex |  ]
]

{ #category : 'startup - shutdown' }
Golap class >> sessionFile [

	^ self golapDirectory / '.golap'
]

{ #category : 'menus' }
Golap class >> showSettingBrowser [

	<script>
	SettingBrowser new
		changePackageSet: {
				(self packageOrganizer packageNamed: #'Network-Kernel').
				(self packageOrganizer packageNamed: #'Golap-UI') };
		open
]

{ #category : 'startup - shutdown' }
Golap class >> shutDown: aBoolean [

	aBoolean ifTrue: [ self suspend ]
]

{ #category : 'startup - shutdown' }
Golap class >> startUp: aBoolean [

	aBoolean ifTrue: [
		Smalltalk session addDeferredStartupAction: [ self resume ] ]
]

{ #category : 'startup - shutdown' }
Golap class >> suspend [

	[
		| json |
		json := Dictionary new.
		GolapPhantasmicProject asJSON ifNotNil: [ :project |
			json at: 'session' put: project ].
		self sessionFile
			ensureDelete;
			writeStreamDo: [ :stream |
				(NeoJSONWriter on: stream) nextPut: json ] ]
		on: Exception
		do: [ :ex |  ]
]

{ #category : 'accessing' }
Golap >> activeVisualizationDo: aBlock [

	^ (visualizationNotebook selectedPage ifNotNil: #activePresenter)
		  ifNotNil: aBlock
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

{ #category : 'accessing-reference nodes' }
Golap >> addReferenceNode: aGolapNode [

	model addReferenceNode: aGolapNode.
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

	aGolapModel resetMerges.
	merges do: [ :assoc |
			aGolapModel
				mergeNodes: (assoc value
						 collect: [ :id | aGolapModel nodes at: id ifAbsent: [ nil ] ]
						 thenSelect: #notNil)
				named: assoc key ].
	^ aGolapModel
]

{ #category : 'projects' }
Golap >> asJSON [

	^ self basicAsJSON
		  at: 'url' put: url asString;
		  at: 'query' put: query;
		  at: 'dimensions'
		  put: (dimensions associations collect: [ :assoc |
						   {
							   assoc key.
							   assoc value asJSON } ]);
		  at: 'merges' put: (merges collect: [ :assoc |
						   {
							   assoc key.
							   assoc value } ]);
		  at: 'pins' put: pins asArray;
		  at: 'selections' put: selections asArray;
		  at: 'baseList' put: baseList selectedItem;
		  at: 'frontList' put: frontList selectedItem;
		  at: 'edgesAppearance' put: edgesAppearancePresenter asJSON;
		  at: 'colorsAppearance' put: colorsAppearancePresenter asJSON;
		  at: 'itemInfoRetriever' put: itemInfoRetriever asJSON;
		  at: 'itemList' put: itemList asJSON;
		  at: 'edgeList' put: edgeList asJSON;
		  at: 'comment' put: commentText text;
		  at: 'polishOverview' put: polishOverviewPresenter asJSON;
		  at: 'articulationPointOverview'
		  put: articulationPointOverviewPresenter asJSON;
		  at: 'elaboration' put: elaborationPresenter asJSON;
		  at: 'dandelion' put: dandelionPresenter asJSON;
		  at: 'hedge' put: hedgePresenter asJSON;
		  at: 'heatmap' put: heatmapPresenter asJSON;
		  at: 'visualizationNotebook-selectedPageIndex'
		  put: visualizationNotebook selectedPageIndex;
		  at: 'showsPhotoimages' put: self showsPhotoimages;
		  yourself
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
	itemInfoRetriever ifNotNil: [
		itemInfoRetriever authenticateBlock: aBlock ]
]

{ #category : 'testing' }
Golap >> basicShowsPhotoimages: aBoolean [

	itemsAppearancePresenter basicShowsPhotoimages: aBoolean
]

{ #category : 'private' }
Golap >> blockUpdateModelWhile: aBlock [

	aBlock value
]

{ #category : 'layouts' }
Golap >> buttonHeight [

	^ self class buttonHeight
]

{ #category : 'layouts' }
Golap >> centerPaneLayout [

	^ SpBoxLayout newHorizontal
		  add: leftPaneOpenCloseButton width: 16;
		  add: visualizationNotebook expand: true;
		  yourself
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

{ #category : 'accessing-markers' }
Golap >> colorMarkers [

	^ itemList colorMarkers
]

{ #category : 'accessing-markers' }
Golap >> colorMarkersAndNodesDo: aBlock [

	itemList colorMarkersAndNodesDo: aBlock
]

{ #category : 'accessing' }
Golap >> comment [

	^ commentText text
]

{ #category : 'accessing' }
Golap >> comment: aString [

	commentText text: aString
]

{ #category : 'ui requests' }
Golap >> confirmOpen [

	model ifNotNil: [
			| numNodes numConnected numEdges |
			numNodes := 0.
			numConnected := 0.
			numEdges := 0.
			model nodesDo: [ :node |
					numNodes := numNodes + 1.
					node isIsolated ifFalse: [ numConnected := numConnected + 1 ] ].
			model edgesDo: [ :edge | numEdges := numEdges + 1 ].
			(self
				 confirm:
					 '開きますか？' , String cr , '総商品数:' , numNodes printString
					 , ' 関連付き商品数:' , numConnected printString , ' 関連数:'
					 , numEdges printString
				 label: '確認') = true ifFalse: [ GolapAborted signal ] ]
]

{ #category : 'operations' }
Golap >> copyAllFromQueryViewTree [
	Clipboard
		clipboardText: (GolapJSON toString: queryViewTree roots asDictionary)
]

{ #category : 'operations' }
Golap >> copyFromQueryViewTree [

	queryViewTree selectedItem
		ifNotNil: [ :assoc |
		Clipboard clipboardText: (GolapJSON toString: assoc value) ]
		ifNil: [
				Clipboard clipboardText:
					(GolapJSON toString: queryViewTree roots asDictionary) ]
]

{ #category : 'accessing-colors' }
Golap >> decliningColor [
	^ colorsAppearancePresenter decliningColor
]

{ #category : 'layouts' }
Golap >> defaultLayout [

	<spec>
	^ SpPanedLayout newHorizontal
		  positionOfSlider: 0.25;
		  add: self leftPaneLayout;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 0.8;
				   add: self centerPaneLayout;
				   add: self rightPaneLayout;
				   yourself);
		  yourself
]

{ #category : 'accessing-dimensions' }
Golap >> dimensionAt: aString [
	^ dimensions at: aString ifAbsent: [ nil ]
]

{ #category : 'accessing-dimensions' }
Golap >> dimensionsDo: aBlock [
	dimensions do: aBlock
]

{ #category : 'accessing' }
Golap >> edgeEvaluator [

	^ edgesAppearancePresenter edgeEvaluator
]

{ #category : 'accessing' }
Golap >> edgeEvaluator: aGolapEdgeEvaluator [

	edgesAppearancePresenter selectEdgeEvaluator: aGolapEdgeEvaluator
]

{ #category : 'accessing' }
Golap >> edgeEvaluators [

	^ edgesAppearancePresenter edgeEvaluators
]

{ #category : 'accessing' }
Golap >> edgeEvaluators: aCollectionOfGolapEdgeEvaluator [

	edgesAppearancePresenter edgeEvaluators:
		aCollectionOfGolapEdgeEvaluator
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

{ #category : 'accessing' }
Golap >> friend [

	^ edgesAppearancePresenter friend
]

{ #category : 'projects' }
Golap >> fromJSON: aDictionary [

	self blockUpdateModelWhile: [
			aDictionary
				at: 'url' ifPresent: [ :string | url := string asZnUrl ];
				at: 'query' ifPresent: [ :dict | query := dict ];
				at: 'dimensions' ifPresent: [ :array |
						array do: [ :pair |
									self
										addDimension: (GolapModel new
												 fromJSON: pair second;
												 yourself)
										named: pair first ] ];
				at: 'baseList' ifPresent: [ :string |
					string ifNotNil: [
							(baseList items includes: string) ifTrue: [
								baseList selectItem: string ] ] ];
				at: 'frontList' ifPresent: [ :string |
					string ifNotNil: [
							(frontList items includes: string) ifTrue: [
								frontList selectItem: string ] ] ];
				at: 'merges' ifPresent: [ :array |
					model ifNotNil: [
							merges := (array collect: [ :pair | pair first -> pair second ])
								          asOrderedCollection.
							model setMerges: merges ] ];
				at: 'pins'
				ifPresent: [ :array | pins := array asOrderedCollection ];
				at: 'selections'
				ifPresent: [ :array | selections := array asSet ];
				at: 'edgesAppearance'
				ifPresent: [ :json | edgesAppearancePresenter fromJSON: json ];
				at: 'colorsAppearance'
				ifPresent: [ :json | colorsAppearancePresenter fromJSON: json ];
				at: 'itemInfoRetriever' ifPresent: [ :json |
					itemInfoRetriever := GolapItemInfoRetriever fromJSON: json.
					itemsAppearancePresenter updatePhotoimageRetrievers.
					self startPhotoimageRetrievingProcess ];
				at: 'itemList' ifPresent: [ :json | itemList fromJSON: json ];
				at: 'edgeList' ifPresent: [ :json | edgeList fromJSON: json ];
				at: 'comment' ifPresent: [ :text | commentText text: text ];
				at: 'polishOverview'
				ifPresent: [ :json | polishOverviewPresenter fromJSON: json ];
				at: 'articulationPointOverview'
				ifPresent: [ :json |
				articulationPointOverviewPresenter fromJSON: json ];
				at: 'elaboration'
				ifPresent: [ :json | elaborationPresenter fromJSON: json ];
				at: 'dandelion'
				ifPresent: [ :json | dandelionPresenter fromJSON: json ];
				at: 'hedge' ifPresent: [ :json | hedgePresenter fromJSON: json ];
				at: 'heatmap'
				ifPresent: [ :json | heatmapPresenter fromJSON: json ];
				at: 'visualizationNotebook-selectedPageIndex'
				ifPresent: [ :integer |
				visualizationNotebook selectPageIndex: integer ];
				at: 'showsPhotoimages'
				ifPresent: [ :bool | self basicShowsPhotoimages: bool ].
			self basicFromJSON: aDictionary.
			self selectedPageChanged ]
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
			menu addGroup: [ :group |
					(model isReferenceNode: aGolapNode)
						ifTrue: [
								group addItem: [ :item |
										item
											name: 'remove from reference';
											action: [ self removeReferenceNode: aGolapNode ] ] ]
						ifFalse: [
								group addItem: [ :item |
										item
											name: 'add to reference';
											action: [ self addReferenceNode: aGolapNode ] ] ] ].
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
						action: [ aGolapNode inspect ] ] ].
	^ menu
]

{ #category : 'accessing-presets' }
Golap >> golapDirectory [

	^ self class golapDirectory
]

{ #category : 'accessing-colors' }
Golap >> growingColor [
	^ colorsAppearancePresenter growingColor
]

{ #category : 'menu' }
Golap >> iconForCircleColor: aColor [

	^ itemList iconForCircleColor: aColor
]

{ #category : 'accessing' }
Golap >> ids [

	^ model ifNil: [ #(  ) ] ifNotNil: [ model nodes keys ]
]

{ #category : 'private' }
Golap >> ifNotActive: aBlock [

	adapter ifNil: [ ^ aBlock value ].
	adapter widget ifNil: [ ^ aBlock value ].
	adapter widget world ifNil: [ ^ aBlock value ]
]

{ #category : 'operations-photoimages' }
Golap >> imageCacheAt: aGolapNode do: aBlock [

	aGolapNode idsDo: [ :id | imageCache at: id ifPresent: aBlock ]
]

{ #category : 'operations-photoimages' }
Golap >> imageCacheAt: aGolapNode ifAbsent: errorBlock [

	aGolapNode idsDo: [ :id |
		imageCache at: id ifPresent: [ :form | ^ form ] ].
	^ errorBlock value
]

{ #category : 'operations-photoimages' }
Golap >> imageCacheAt: aGolapNode put: aForm [

	^ imageCache at: aGolapNode id put: aForm
]

{ #category : 'accessing' }
Golap >> imageRepositoryUrl: aString [

	itemInfoRetriever imageRepositoryUrl: aString
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
	imageCache := Dictionary new: 1024
]

{ #category : 'initialization' }
Golap >> initializePresenters [

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
	commentText := self newText
		               whenTextChangedDo: [
			               self window ifNotNil: [ :window |
					               window title: self windowTitle ] ];
		               yourself.
	saveAsPngButton := self newButton
		                   label: 'save as PNG...';
		                   action: [ self saveAsPNG ];
		                   yourself.
	saveAsSvgButton := self newButton
		                   label: 'save as SVG...';
		                   action: [ self saveAsSVG ];
		                   yourself.
	resendQueryButton := self newButton
		                     label: 'resend query';
		                     action: [ self resendQuery ];
		                     yourself.
	queryViewTree := (self instantiate: GolapTreeTablePresenter)
		                 addColumn:
			                 (SpStringTableColumn evaluated: [ :assoc |
						                  | string |
						                  string := assoc key , ' : '
						                            , (GolapJSON toString: assoc value).
						                  queryViewTree contentWidth:
								                  (TextStyle defaultFont widthOfString: string).
						                  string ]);
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
	polishOverviewPresenter := self instantiate:
		                           (GolapPolishOverviewPresenter new golap:
			                            self).
	articulationPointOverviewPresenter := self instantiate:
		                                      (GolapArticulationPointOverviewPresenter
			                                       new golap: self).
	elaborationPresenter := self instantiate:
		                        (GolapElaborationPresenter new golap: self).
	dandelionPresenter := self instantiate:
		                      (GolapDandelionChartPresenter new golap: self).
	hedgePresenter := self instantiate:
		                  (GolapHedgeChartPresenter new golap: self).
	heatmapPresenter := self instantiate:
		                    (GolapClusteredHeatmapPresenter new golap: self).
	visualizationNotebook := self newNotebook
		                         addPageTitle: '研磨'
		                         provider: [ polishOverviewPresenter ];
		                         addPageTitle: '要衝点図'
		                         provider: [
			                         articulationPointOverviewPresenter ];
		                         addPageTitle: '特化グラフ'
		                         provider: [ elaborationPresenter ];
		                         addPageTitle: 'たんぽぽ図'
		                         provider: [ dandelionPresenter ];
		                         addPageTitle: '生垣図'
		                         provider: [ hedgePresenter ];
		                         addPageTitle: 'ヒートマップ'
		                         provider: [ heatmapPresenter ];
		                         whenSelectedPageChangedDo: [
			                         self selectedPageChanged ];
		                         yourself.
	leftPaneOpenCloseButton := self newButton
		                           state: false;
		                           action: [
			                           self leftPaneOpenCloseButtonClicked ];
		                           yourself.
	self updateLeftPaneOpenCloseButton.
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
	aWindowPresenter whenWillCloseDo: [ :announcement |
			self confirmClose
				ifTrue: [ announcement allowClose ]
				ifFalse: [ announcement denyClose ] ].
	aWindowPresenter whenClosedDo: [ self saveQueryRecord ]
]

{ #category : 'private' }
Golap >> isUpdateModelBlocked [

	| current |
	current := thisContext.
	[
		current := current sender.
		current ifNil: [ ^ false ].
		(current receiver == self and: [
			 current selector = #blockUpdateModelWhile: ]) ifTrue: [ ^ true ] ]
		repeat
]

{ #category : 'accessing' }
Golap >> itemFieldQuerySpec: aDictionary [

	itemInfoRetriever itemFieldQuerySpec: aDictionary
]

{ #category : 'accessing' }
Golap >> itemInfoRetriever [

	^ itemInfoRetriever
]

{ #category : 'accessing' }
Golap >> itemInfoRetriever: aGolapItemInfoRetriever [

	itemInfoRetriever := aGolapItemInfoRetriever.
	itemsAppearancePresenter updatePhotoimageRetrievers
]

{ #category : 'accessing-widgets' }
Golap >> itemView [
	^ itemView
]

{ #category : 'accessing' }
Golap >> itemViewUrl: aString [

	itemInfoRetriever golapServerUrl: aString
]

{ #category : 'layouts' }
Golap >> leftPaneLayout [

	<script: 'self new open'>
	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: frontList;
				   add: baseList)
		  height: self buttonHeight;
		  add: edgesAppearancePresenter expand: true;
		  add: itemsAppearancePresenter expand: false;
		  add: colorsAppearancePresenter height: 200;
		  add: 'コメント' expand: false;
		  add: commentText;
		  yourself
]

{ #category : 'updating' }
Golap >> leftPaneOpenCloseButtonClicked [

	leftPaneOpenCloseButton state: leftPaneOpenCloseButton state not.
	self updateLeftPaneOpenCloseButton.
	self layout positionOfSlider: (leftPaneOpenCloseButton state
			 ifTrue: [ 0.0 ]
			 ifFalse: [ 0.25 ]).
	self layout children second withAdapterDo: [ :a |
			a widgetDo: [ :w |
					| slider |
					slider := w submorphs second.
					self layout children second positionOfSlider:
						slider target width
						/ (slider target width + slider targetAfter width) ] ].
	self layout: self layout
]

{ #category : 'history' }
Golap >> loadFromQueryRecord: aGolapQueryRecord [

	queryRecord := aGolapQueryRecord.
	aGolapQueryRecord graph ifNotNil: [ :graph |
			dimensions removeAll.
			graph keysAndValuesDo: [ :name :json |
				dimensions at: name put: (GolapModel fromJSON: json) ].
			self updateDimensions ]
]

{ #category : 'accessing-markers' }
Golap >> markedNodes [

	^ itemList markedNodes
]

{ #category : 'accessing-markers' }
Golap >> markersAtNode: aGolapNode do: aBlock [

	itemList markersAtNode: aGolapNode do: aBlock
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
			itemList markerDropList items
				select: #isColorMarker
				thenDo: [ :marker |
						| ids |
						ids := model nodes
							       select: [ :node | marker includesNode: node ]
							       thenCollect: #id.
						ids size > 1 ifTrue: [
								group addItem: [ :menuItem |
										menuItem
											name: '';
											icon: marker icon;
											action: [
													(self mergeNodes: ids copy) ifNotNil: [ :newId |
																itemList add: (model nodeAt: newId) toMarker: marker.
																itemList currentMarker: marker ] ] ] ] ] ].
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
								  itemList updateItemsList.
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

{ #category : 'accessing' }
Golap >> model [
	^ model
]

{ #category : 'accessing' }
Golap >> model: aGolapModel [

	self model: aGolapModel forceUpdate: true.
"	polishOverviewPresenter
		updateCanvas;
		zoomToFit.
	friendOverviewPresenter
		updateCanvas;
		zoomToFit.
	articulationPointOverviewPresenter
		updateCanvas;
		zoomToFit.
	elaborationPresenter
		updateCanvas;
		zoomToFit"
]

{ #category : 'accessing' }
Golap >> model: aGolapModel forceUpdate: aBoolean [

	(aBoolean == false and: [ aGolapModel == model ]) ifTrue: [ ^ self ].
	model := aGolapModel.
	model ifNotNil: [
			self
				updateGlobalImageAfter: [
						model announcer
							when: GolapModelChangedAnnouncement
							send: #updatePhotoimages
							to: self.
						self unselectAll.
						edgesAppearancePresenter updateModel: model.
						itemList updateItemsList ]
				layout: aBoolean ].
	self announceGolapModelUpdated
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
Golap >> nodeEvaluator [

	^ edgesAppearancePresenter nodeEvaluator
]

{ #category : 'accessing' }
Golap >> nodeEvaluator: aGolapNodeEvaluator [

	edgesAppearancePresenter selectNodeEvaluator: aGolapNodeEvaluator
]

{ #category : 'accessing' }
Golap >> nodeEvaluators [

	^ edgesAppearancePresenter nodeEvaluators
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
Golap >> numLabels [
	^ itemsAppearancePresenter numLabels
]

{ #category : 'accessing' }
Golap >> numNodes [

	^ model nodes size
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

{ #category : 'operations-photoimages' }
Golap >> photoimageRetrievalProgressBar [

	^ itemsAppearancePresenter photoimageRetrievalProgressBar
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
				UIManager default alert: 'サーバタイムアウト'.
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
								              { ((aReadStream upTo: Character lf)
								               , ',effective') }
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
											          values:
												          (dataframe columnNames collect: [ :n | 0 ]))
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

	[
		self presetQueryFile ensureCreateFile readStreamDo: [ :stream |
			^ GolapJSON fromStream: stream ] ]
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
	pins := nil.
	selections := nil.
	font := nil.
	itemView := nil.
	imageCache := nil.
	super release
]

{ #category : 'accessing-reference nodes' }
Golap >> removeReferenceNode: aGolapNode [

	model removeReferenceNode: aGolapNode.
	self updateGlobalImage
]

{ #category : 'ui requests' }
Golap >> requestFileToSave: aString extensions: anArrayOfString [

	| dialog |
	dialog := StSaveFilePresenter new.
	dialog
		title: aString;
		extensions: anArrayOfString.
	dialog defaultFolder: self golapDirectory.
	dialog openModal.
	dialog cancelled ifFalse: [
		dialog selectedEntry ifNotNil: [ :ref | ^ ref ] ].
	^ nil
]

{ #category : 'operations' }
Golap >> resendQuery [

	| api golap |
	(self url isNil or: [ self query isNil ]) ifTrue: [ ^ self ].
	api := GolapApiClient
		       url: self url
		       query: (GolapJSON toString: self query)
		       comment: self comment
		       serverConfig: itemInfoRetriever serverConfig
		       itemFieldQuerySpec: itemInfoRetriever itemFieldQuerySpec
		       authenticateBlock: self authenticateBlock.
	golap := Golap new.
	[
		golap
			queryRecord: queryRecord hideDuplicate;
			itemInfoRetriever:
				(GolapServerProductInfoRetriever fromApiClient: api);
			authenticateBlock: api authenticateBlock;
			query: (GolapJSON fromString: api query);
			url: api url;
			comment: api comment;
			imageRepositoryUrl: api imageUrl;
			itemFieldQuerySpec: api itemFieldQuerySpec;
			itemViewUrl: api url ]
		on: Error
		do: [ :ex | UIManager default alert: 'クエリ送信失敗' , api url asString ].
	api readStream ifNotNil: [ :readStream |
			readStream ifNil: [ golap delete ] ifNotNil: [
					readStream isString
						ifTrue: [ UIManager default alert: readStream ]
						ifFalse: [
								Cursor wait showWhile: [
										UIManager default informUserDuring: [ :bar |
												bar
													min: 0;
													max: readStream size.
												golap blockUpdateModelWhile: [
														| d |
														d := 0.
														bar label:
															'ディメンジョン (' , (d := d + 1) asString , ') 読み込み中'.
														[
															bar value: readStream position.
															readStream atEnd ] whileFalse: [
															golap readDimensionFrom: readStream ].
														bar label: 'グラフ更新中 (' , d asString , ')'.
														golap updateDimensions ].
												golap confirmOpen.
												golap open maximize.
												golap updateModel ] ] ] ] ]
]

{ #category : 'accessing-colors' }
Golap >> retreatingColor [
	^ colorsAppearancePresenter retreatingColor
]

{ #category : 'operations-photoimages' }
Golap >> retrieveItemInfoFor: aGolapNode [

	^ itemInfoRetriever ifNotNil: [
		  itemInfoRetriever productDataFor: aGolapNode ]
]

{ #category : 'operations-photoimages' }
Golap >> retrievePhotoimages [

	model ifNotNil: [
			| agenda total tried done |
			agenda := IdentitySet new.
			model edgesDo: [ :edge |
					edge node1 photoimage ifNil: [
						self
							imageCacheAt: edge node1
							ifAbsent: [ agenda add: edge node1 ] ].
					edge node2 photoimage ifNil: [
						self
							imageCacheAt: edge node2
							ifAbsent: [ agenda add: edge node2 ] ] ].
			agenda := agenda asArray.
			total := agenda size.
			done := 0.
			tried := 0.
			agenda := agenda reject: [ :node |
					          tried := tried + 1.
					          self photoimageRetrievalProgressBar
						          value: tried asFloat / total asFloat
						          message:
							          '画像取得中 (' , done asString , ') ' , tried asString
							          , ' / ' , total asString , ')'.
					          self ifNotActive: [
							          photoImageRetrievingProcess := nil.
							          Processor activeProcess terminate ].
					          (itemInfoRetriever photoimageFor: node)
						          ifNotNil: [ :photoimage |
								          node photoimage:
									          (photoimage scaledToSize:
										           self photoimageSize asPoint).
								          self imageCacheAt: node put: node photoimage.
								          done := done + 1.
								          done \\ 10 = 0 ifTrue: [
										          self activeVisualizationDo: [ :presenter |
												          (presenter respondsTo: #updateNodeShapes)
													          ifTrue: [ presenter updateNodeShapes ] ] ].
								          true ]
						          ifNil: [ false ] ].
			self photoimageRetrievalProgressBar
				value: 1
				message: '画像取得完了 (' , agenda size asString , '個取得不可)'.
			self updateGlobalImage ]
]

{ #category : 'layouts' }
Golap >> rightPaneLayout [

	^ SpBoxLayout newVertical
		  add: saveAsSvgButton height: self buttonHeight;
		  add: saveAsPngButton height: self buttonHeight;
		  add: resendQueryButton height: self buttonHeight;
		  add: queryViewTree height: 200;
		  add: itemNotebook
]

{ #category : 'operations' }
Golap >> saveAsPNG [

	(self requestFileToSave: 'PNG ファイルに保存します' extensions: #( 'png' ))
		ifNotNil: [ :ref | self saveAsPNG: ref ]
]

{ #category : 'operations' }
Golap >> saveAsPNG: aFileReference [

	self activeVisualizationDo: [ :visualization |
			visualization canvas ifNotNil: [ :canvas |
					| oldMorph oldExtent oldPosition oldFixedShapes rect |
					oldMorph := canvas morph.
					oldExtent := canvas extent.
					oldPosition := canvas camera position.
					oldFixedShapes := canvas fixedShapes.
					canvas fixedShapes: RSGroup new.
					rect := canvas encompassingRectangle.
					canvas extent: rect extent + (10 @ 10).
					canvas camera position: rect center negated.
					canvas pngExporter
						withoutFixedShapes;
						exportToFile: aFileReference.
					canvas
						morph: oldMorph;
						extent: oldExtent.
					canvas camera position: oldPosition.
					canvas fixedShapes: oldFixedShapes.
					canvas signalUpdate ] ]
]

{ #category : 'operations' }
Golap >> saveAsSVG [

	(self requestFileToSave: 'SVG ファイルに保存します' extensions: #( 'svg' ))
		ifNotNil: [ :ref | self saveAsSVG: ref ]
]

{ #category : 'operations' }
Golap >> saveAsSVG: aFileReference [

	self activeVisualizationDo: [ :visualization |
			visualization canvas ifNotNil: [ :canvas |
					| oldMorph oldExtent oldPosition oldFixedShapes rect |
					oldMorph := canvas morph.
					oldExtent := canvas extent.
					oldPosition := canvas camera position.
					oldFixedShapes := canvas fixedShapes.
					canvas fixedShapes: RSGroup new.
					rect := canvas encompassingRectangle.
					canvas extent: rect extent + (10 @ 10).
					canvas camera position: rect center negated.
					canvas svgCairoExporter
						withoutFixedShapes;
						exportToFile: aFileReference.
					canvas
						morph: oldMorph;
						extent: oldExtent.
					canvas camera position: oldPosition.
					canvas fixedShapes: oldFixedShapes.
					canvas signalUpdate ] ]
]

{ #category : 'operations' }
Golap >> saveFullImage [

	(self requestFileToSave: 'PNG ファイルに保存します' extensions: #( 'png' ))
		ifNotNil: [ :ref | self saveAsPNG: ref ]
]

{ #category : 'history' }
Golap >> saveQueryRecord [

	queryRecord ifNotNil: [
		queryRecord comment:
			(commentText text asString trim ifEmpty: [ nil ]).
		queryRecord graph: (dimensions associations collect: [ :assoc |
				 assoc key -> assoc value asJSON ]) asOrderedDictionary.
		queryRecord hideSave ]
]

{ #category : 'accessing-selection' }
Golap >> select: aGolapNode [

	aGolapNode idsDo: [ :id | selections add: id ].
	self showItemView: aGolapNode.
	self updateSelection
]

{ #category : 'accessing-selection' }
Golap >> selectAll: aCollectionOfGolapNode [

	aCollectionOfGolapNode do: [ :node |
		node idsDo: [ :id | selections add: id ] ].
	self showItemView: aCollectionOfGolapNode anyOne.
	self updateSelection
]

{ #category : 'accessing-dimensions' }
Golap >> selectedBaseDimension [
	^ dimensions at: baseList selectedItem ifAbsent: [ nil ]
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

{ #category : 'updating' }
Golap >> selectedPageChanged [

	self updateItemsList.
	visualizationNotebook selectedPage activePresenter ifNotNil: [ :p |
			(p respondsTo: #activateOnNotebookPage) ifTrue: [
				p activateOnNotebookPage ].
			(p respondsTo: #updateCanvas) ifTrue: [ p updateCanvas ] ]
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
		v idsDo: [ :id | newSelections add: id ] ].
	selections = newSelections ifFalse: [
		selections := newSelections.
		self showItemView: aCollectionOfGolapNode last.
		self updateSelection ]
]

{ #category : 'accessing' }
Golap >> setQuery: aDictionary [

	query := aDictionary.
	queryViewTree roots:
		(query keys asSortedCollection collect: [ :key |
			 key -> (query at: key) ]).
	itemInfoRetriever ifNotNil: [ itemInfoRetriever query: aDictionary ]
]

{ #category : 'accessing-selection' }
Golap >> setSelections: aCollectionOfString [

	| newSelections |
	newSelections := aCollectionOfString asSet.
	selections = newSelections ifFalse: [
		selections := newSelections.
		itemList selectedItem ifNotNil: [ :item |
			self showItemView: (model nodeAt: item) ].
		self updateSelection ]
]

{ #category : 'operations' }
Golap >> showItemView: aGolapNode [
	aGolapNode ifNotNil: [ itemView node: aGolapNode ]
]

{ #category : 'testing' }
Golap >> showsNode: aGolapNode [

	self activeVisualizationDo: [ :visualizationPresenter |
		^ visualizationPresenter showsNode: aGolapNode ].
	^ false
]

{ #category : 'testing' }
Golap >> showsPhotoimages [

	^ itemsAppearancePresenter showsPhotoimages
]

{ #category : 'testing' }
Golap >> showsPhotoimages: aBoolean [

	itemsAppearancePresenter showsPhotoimages: aBoolean
]

{ #category : 'updating' }
Golap >> showsPhotoimagesChanged [

	self application showWaitCursorWhile: [
			self
				updatePhotoimages;
				updateGlobalImage ]
]

{ #category : 'accessing-dimensions' }
Golap >> silentAddDimension: aGolapOverviewModel named: aString [
	dimensions at: aString put: aGolapOverviewModel.
	^ aGolapOverviewModel
]

{ #category : 'accessing-selection' }
Golap >> silentlySelect: aGolapNode [

	aGolapNode idsDo: [ :id | selections add: id ]
]

{ #category : 'accessing-selection' }
Golap >> silentlyUnselect: aGolapNode [

	aGolapNode idsDo: [ :id | selections remove: id ifAbsent: [ ] ]
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

{ #category : 'operations-photoimages' }
Golap >> startPhotoimageRetrievingProcess [

	self stopPhotoimageRetrievingProcess.
	(itemInfoRetriever isNil or: [
		 itemInfoRetriever hasPhotoImage not ]) ifTrue: [ ^ self ].
	photoImageRetrievingProcess := [ self retrievePhotoimages ] forkAt:
		                               Processor userBackgroundPriority
]

{ #category : 'operations-photoimages' }
Golap >> stopPhotoimageRetrievingProcess [

	photoImageRetrievingProcess ifNotNil: [ 
		photoImageRetrievingProcess terminate.
		photoImageRetrievingProcess := nil ]
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
	itemList updateItemsList
]

{ #category : 'accessing-selection' }
Golap >> unselect: aGolapNode [

	aGolapNode idsDo: [ :id | selections remove: id ifAbsent: [  ] ].
	self updateSelection
]

{ #category : 'accessing-selection' }
Golap >> unselectAll [

	selections removeAll.
	self updateSelection
]

{ #category : 'accessing-selection' }
Golap >> unselectAll: aCollectionOfGolapNode [

	aCollectionOfGolapNode do: [ :node |
		node idsDo: [ :id | selections remove: id ifAbsent: [  ] ] ].
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

	(visualizationNotebook selectedPage ifNotNil: #activePresenter)
		ifNotNil: [ :p |
		(p respondsTo: #updateCanvas) ifTrue: [ p updateCanvas ] ].
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
					self updateGlobalImage ] ]
]

{ #category : 'updating' }
Golap >> updateItemView [
	self
		showItemView:
			(model
				nodeAt: itemList selectedItem
				ifAbsent: [ ^ self ])
]

{ #category : 'updating' }
Golap >> updateItemsList [

	itemList updateItemsList
]

{ #category : 'updating' }
Golap >> updateLeftPaneOpenCloseButton [

	leftPaneOpenCloseButton label: (leftPaneOpenCloseButton state = true
			 ifTrue: [ '>' ]
			 ifFalse: [ '<' ])
]

{ #category : 'updating' }
Golap >> updateModel [

	self model: self selectedModel.
	self model edgeEvaluators: self edgeEvaluators.
	self model nodeEvaluators: self nodeEvaluators.
	self model friend: self friend.
	self isUpdateModelBlocked ifTrue: [ ^ self ].
	itemList updateItemsList.
	edgeList modelChanged.
	edgesAppearancePresenter refreshEvaluatorList.
	self
		updatePhotoimages;
		startPhotoimageRetrievingProcess.
	self visualizationsDo: [ :presenter |
			(presenter respondsTo: #updateCanvas) ifTrue: [
				presenter updateCanvas ] ].
	self activeVisualizationDo: [ :presenter |
			(presenter respondsTo: #ensureNodePositions) ifTrue: [
				presenter ensureNodePositions ] ]
]

{ #category : 'updating' }
Golap >> updatePhotoimages [

	self model ifNotNil: [ :golapModel |
			golapModel nodesDo: [ :node |
					node photoimage ifNil: [
						self imageCacheAt: node do: [ :form | node photoimage: form ] ] ] ]
]

{ #category : 'private' }
Golap >> updateQuery [
	itemList updateItemsList
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

	url := aZnUrl asUrl
]

{ #category : 'accessing' }
Golap >> visibleEdges [

	^ edgesAppearancePresenter visibleEdges
]

{ #category : 'enumerating' }
Golap >> visualizationsDo: aBlock [

	visualizationNotebook pages do: aBlock
]

{ #category : 'accessing' }
Golap >> windowTitle [

	^ 'グラフ (' , (commentText
		   ifNotNil: [
				   (commentText text asString lines
					    ifNotEmpty: #first
					    ifEmpty: [ '' ]) trim ]
		   ifNil: [ '' ]) , ')'
]

{ #category : 'accessing-presets' }
Golap >> writePresetQueries: anArrayOfString [
	self presetQueryFile ensureDelete
		writeStreamDo: [ :stream | ^ (NeoJSONWriter on: stream) nextPut: anArrayOfString ]
]
