Class {
	#name : 'GolapNetworkClientPresenter',
	#superclass : 'SpPresenter',
	#traits : 'TGolapSnapshotablePresenter',
	#classTraits : 'TGolapSnapshotablePresenter classTrait',
	#instVars : [
		'urlInput',
		'presetUrlButton',
		'username',
		'password',
		'serverConfigTree',
		'serverConfig',
		'fieldsAndValuesCache',
		'queryPresenter',
		'queryText',
		'usesRawQuery',
		'queryNotebook',
		'usesRawQueryText',
		'commentText',
		'queryHistoryPresenter',
		'usesQueryHistory',
		'queryPalettePresenter',
		'resetButton',
		'saveButton',
		'openButton'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'menus' }
GolapNetworkClientPresenter class >> golapMenuOn: aBuilder [

	<worldMenu>
	<golapMenu>
	(aBuilder item: #GolapServerQuery)
		label: 'サーバクエリを開く...';
		iconName: #remote;
		parent: #GolapServer;
		order: 40;
		target: self;
		selector: #open;
		help: 'サーバクエリを編集して送信するウィンドウを開きます'
]

{ #category : 'menus' }
GolapNetworkClientPresenter class >> open [

	^ self new open
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> authenticateBlock [
	^ [ :auth | 
	username ifNil: [ username := UIManager default request: 'username' ].
	username
		ifNotNil: [ password
				ifNil: [ password := UIManager default requestPassword: 'password' ].
			password
				ifNotNil: [ auth value: username value: password ]
				ifNil: [ username := nil ] ] ]
]

{ #category : 'operations' }
GolapNetworkClientPresenter >> clearPreviewFilterField [

	queryPresenter clearPreviewFilterField
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> comment [

	^ commentText text
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> comment: aString [

	commentText text: aString
]

{ #category : 'ui requests' }
GolapNetworkClientPresenter >> confirm: queryString label: titleString [

	^ self application newConfirm
		  title: titleString;
		  label: queryString;
		  openModal
]

{ #category : 'layout' }
GolapNetworkClientPresenter >> defaultLayout [

	<script: 'self new open'>
	<spec>
	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: urlInput;
				   add: presetUrlButton width: 20)
		  height: self class inputTextHeight;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 0.8;
				   add: queryNotebook;
				   add: (SpBoxLayout newVertical
						    add: 'サーバパラメータ' expand: false;
						    add: serverConfigTree;
						    add: 'コメント' expand: false;
						    add: commentText height: self class inputTextHeight * 4;
						    yourself));
		  add: (SpBoxLayout newHorizontal
				   hAlignEnd;
				   add: resetButton expand: false;
				   add: saveButton expand: false;
				   add: openButton expand: false;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'defaults' }
GolapNetworkClientPresenter >> defaultQuery [
	^ Dictionary new
		at: 'query'
			put:
			(Dictionary new
				at: 'traFilter' put: '';
				at: 'itemFilter' put: '';
				at: 'selCond'
					put:
					(Dictionary new
						at: 'minJac' put: 0.0;
						at: 'minPMI' put: 0.0;
						at: 'minConf' put: 0.0;
						at: 'minSup' put: 0.0;
						at: 'minLift' put: 0.0;
						yourself);
				at: 'isolatedNodes' put: 'true';
				at: 'sendMax' put: 1000;
				at: 'sortKey' put: 'sup';
				yourself);
		at: 'deadlineTimer' put: 600;
		yourself
]

{ #category : 'defaults' }
GolapNetworkClientPresenter >> defaultUrl [
	^ 'http://' copy
]

{ #category : 'operations' }
GolapNetworkClientPresenter >> dumpToFile [

	UIManager default informUserDuring: [ :progress |
			| readStream |
			readStream := (GolapApiClient
				               url: self url
				               query: self query
				               comment: self comment
				               serverConfig: self serverConfig
				               itemFieldQuerySpec: self itemFieldQuerySpec
				               authenticateBlock: self authenticateBlock)
				              readStream.
			readStream ifNil: [
				^ UIManager default alert: 'Failed to get server response.' ].
			(UIManager default
				 chooseForSaveFileReference: 'Save gOLAP data'
				 extensions: #( 'csv' )
				 path: GolapModel coocurrenceDataDirectory) ifNotNil: [ :ref |
					ref writeStreamDo: [ :writeStream |
							[ readStream atEnd ] whileFalse: [
									writeStream
										nextPutAll: (readStream upTo: Character lf);
										nextPut: Character lf ] ] ] ]
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> flushAuth [
	username := nil.
	password := nil
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> flushFieldsAndValuesCache [
	fieldsAndValuesCache removeAll
]

{ #category : 'private' }
GolapNetworkClientPresenter >> flushServerConfig [
	serverConfig := nil.
	queryPresenter ifNotNil: #flushServerConfig
]

{ #category : 'private' }
GolapNetworkClientPresenter >> generateQueryText [

	queryPalettePresenter query: queryPresenter queryDictionary
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> golapDirectory [
	^ (FileLocator documents / 'gOLAP') ensureCreateDirectory
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> imageUrl [
	^ self serverConfig at: 'imageUrl' ifAbsent: [ nil ]
]

{ #category : 'initialization' }
GolapNetworkClientPresenter >> initialExtent [
	^ 1200 @ 700
]

{ #category : 'initialization' }
GolapNetworkClientPresenter >> initialize [

	super initialize.
	fieldsAndValuesCache := Dictionary new
]

{ #category : 'initialization' }
GolapNetworkClientPresenter >> initializePresenters [

	<script: 'GolapQueryPresenter new openWithSpec'>
	urlInput := self newTextInput
		            text: self defaultUrl;
		            whenTextChangedDo: [ :old :new |
			            old ~= new ifTrue: [ self flushAuth ] ];
		            whenSubmitDo: [ :text |
				            self updateServerConfig.
				            queryPresenter
					            resetItemFilterSpec;
					            resetTransactionFilterSpec.
				            queryPalettePresenter url: text trim.
				            queryHistoryPresenter url: text trim ];
		            yourself.
	presetUrlButton := self newButton
		                   icon: (Smalltalk ui icons iconNamed: #back);
		                   action: [ self openPresetUrlDialog ];
		                   yourself.
	queryPresenter := GolapQueryPresenter on: self.
	queryNotebook := self newNotebook
		                 addPage: (self newNotebookPage
				                  title: '基本クエリ';
				                  presenterProvider: [ queryPresenter ];
				                  yourself);
		                 addPage: (self newNotebookPage
				                  title: '高度な条件';
				                  presenterProvider: [ queryPalettePresenter ];
				                  whenRetrievedDo: [
						                  self updateQueryHistoryPresenter.
						                  self generateQueryText ];
				                  yourself);
		                 addPage: (self newNotebookPage
				                  title: '履歴';
				                  presenterProvider: [ queryHistoryPresenter ];
				                  whenRetrievedDo: [
					                  queryHistoryPresenter updateQueryHistoryList ];
				                  yourself);
		                 whenSelectedPageChangedDo: [
				                 usesRawQuery := queryNotebook selectedPageIndex
				                                 = 2.
				                 usesQueryHistory := queryNotebook
					                                     selectedPageIndex = 3.
				                 usesQueryHistory ifTrue: [
					                 openButton ifNotNil: #enable ] ];
		                 yourself.
	usesRawQueryText := false.
	queryPalettePresenter := (self instantiate:
			                          GolapQueryPalettePresenter)
		                         importQueryBlock: [ self generateQueryText ];
		                         yourself.
	usesQueryHistory := false.
	queryHistoryPresenter := self instantiate: GolapQueryHistoryPresenter.
	serverConfigTree := (self instantiate: GolapTreeTablePresenter)
		                    addColumn:
			                    (SpStringTableColumn evaluated: [ :assoc |
						                     | string |
						                     string := assoc key , ' : '
						                               ,
							                               (STONJSON toString: assoc value).
						                     serverConfigTree contentWidth:
								                     (TextStyle defaultFont widthOfString:
										                      string).
						                     string ]);
		                    children: [ :assoc |
				                    assoc value isDictionary
					                    ifTrue: [
							                    assoc value keys asSortedCollection
								                    collect: [ :k | k -> (assoc value at: k) ] ]
					                    ifFalse: [ Array new ] ];
		                    roots:
			                    (serverConfig ifNil: [ #(  ) ] ifNotNil: [
						                     serverConfig keys asSortedCollection
							                     collect: [ :key |
								                     key -> (serverConfig at: key) ] ]);
		                    yourself.
	commentText := self newText.
	resetButton := self newButton
		               label: 'Reset';
		               action: [ self resetQuery ];
		               yourself.
	saveButton := self newButton
		              label: 'Save';
		              action: [ self dumpToFile ];
		              yourself.
	openButton := self newButton
		              label: 'Ok';
		              disable;
		              action: [ self openGolap ];
		              yourself.
	self focusOrder
		add: urlInput;
		add: serverConfigTree.
	self whenBuiltDo: [ :w |
			| font |
			font := TextStyle defaultFont.
			w widget allMorphsDo: [ :m |
				(m respondsTo: #font:) ifTrue: [ m font: font ] ].
			self updateServerConfig ]
]

{ #category : 'initialization' }
GolapNetworkClientPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'サーバクエリ';
		initialExtent: self initialExtent.
	aWindowPresenter whenWillCloseDo: [ :announcement |
			self confirmClose
				ifTrue: [ announcement allowClose ]
				ifFalse: [ announcement denyClose ] ]
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> itemFieldQuerySpec [
	^ queryPresenter ifNotNil: #itemFieldQuerySpec
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> itemFields [
	^ self serverConfig
		ifNotNil: [ :config | 
			(((config at: 'itemAttFile' ifAbsentPut: [ Dictionary new ])
				at: 'strFields'
				ifAbsent: [ String new ]) substrings: ',')
				,
					(((config at: 'itemAttFile' ifAbsentPut: [ Dictionary new ])
						at: 'numFields'
						ifAbsent: [ String new ]) substrings: ',') ]
		ifNil: [ Array new ]
]

{ #category : 'private' }
GolapNetworkClientPresenter >> loadPreset: aDictionary [

	aDictionary
		at: 'url' ifPresent: [ :string | self url: string ];
		at: 'rawQuery' ifPresent: [ :string |
			queryPalettePresenter query: string.
			usesRawQuery := true.
			queryNotebook selectPageIndex: 2 ]
		ifAbsent: [
			queryPresenter loadJSON: aDictionary.
			usesRawQuery := false.
			queryNotebook selectPageIndex: 1 ].
	self updateServerConfig.
	queryPresenter
		resetItemFilterSpec;
		resetTransactionFilterSpec
]

{ #category : 'operations' }
GolapNetworkClientPresenter >> openDialogIfAccepted: aBlock ifCanceled: anotherBlock [

	self clearPreviewFilterField.
	self openDialog
		okAction: [
			usesQueryHistory
				ifTrue: [
					queryHistoryPresenter historyRecord ifNotNil: [ :record |
							aBlock cull: nil cull: record hideDuplicate ] ]
				ifFalse: [
					[
					| queryRecord |
					queryRecord := self recordHiDeHo.
					aBlock
						cull: (GolapApiClient
								 url: self url
								 query: self query
								 comment: self comment
								 serverConfig: self serverConfig
								 itemFieldQuerySpec: self itemFieldQuerySpec
								 authenticateBlock: self authenticateBlock)
						cull: queryRecord ] forkAt: Processor userBackgroundPriority ] ];
		cancelAction: anotherBlock
]

{ #category : 'operations' }
GolapNetworkClientPresenter >> openGolap [

	self clearPreviewFilterField.
	usesQueryHistory
		ifTrue: [
				queryHistoryPresenter historyRecord ifNotNil: [ :record |
						| golap |
						golap := Golap new.
						golap blockUpdateModelWhile: [
							golap loadFromQueryRecord: record hideDuplicate ].
						golap confirmOpen.
						golap open maximize.
						golap updateModel ] ]
		ifFalse: [
				| queryRecord api golap |
				queryRecord := self recordHiDeHo.
				api := GolapApiClient
					       url: self url
					       query: self query
					       comment: self comment
					       serverConfig: self serverConfig
					       itemFieldQuerySpec: self itemFieldQuerySpec
					       authenticateBlock: self authenticateBlock.
				golap := Golap new.
				[
					golap
						queryRecord: queryRecord;
						itemInfoRetriever:
							(GolapServerProductInfoRetriever fromApiClient: api);
						authenticateBlock: api authenticateBlock;
						query: (NeoJSONReader fromString: api query);
						url: api url;
						comment: api comment;
						imageRepositoryUrl: api imageUrl;
						itemFieldQuerySpec: api itemFieldQuerySpec;
						itemViewUrl: api url ]
					on: Error
					do: [ :ex |
							UIManager default alert:
								'Can''t open the given URL: ' , api url asString ].
				golap snapshotData: api readStream do: [ :readStream |
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
																	[
																		bar value: readStream position.
																		readStream atEnd ] whileFalse: [
																		golap readDimensionFrom: readStream ].
																	bar label: 'updating dimensions'.
																	golap updateDimensions.
																	bar label: 'updating models'.

																	bar label: 'updating graph' ].
															golap confirmOpen.
															golap open maximize.
															golap updateModel ] ] ] ] ] ]
]

{ #category : 'operations' }
GolapNetworkClientPresenter >> openPresetUrlDialog [

	| presetUrls urlList |
	presetUrls := self readPresetUrls.
	urlList := SpEditableListPresenter new.
	urlList
		title: 'URL';
		items: presetUrls asOrderedCollection;
		addItemBlock: [ 
			(UIManager default request: '新規プレセット名') ifNotNil: [ :name | 
					self asJSON
						at: 'name' put: name;
						yourself ] ];
		removeItemBlock: [ 
			urlList selectedItem ifNotNil: [ :selection | 
				urlList items remove: selection ifAbsent: [  ].
				urlList refresh ] ];
		display: [ :dict | dict at: 'name' ifAbsent: [ '-' ] ];
		whenSelectionChangedDo: [ 
			([ urlList selectedItem ]
				 on: Error
				 do: [ :ex | ex return: nil ]) ifNotNil: [ :selection | 
				self loadPreset: selection ] ];
		okAction: [ 
			urlList items asArray ~= presetUrls ifTrue: [ 
				self writePreset: urlList items asArray ].
			([ urlList selectedItem ]
				 on: Error
				 do: [ :ex | ex return: nil ]) ifNotNil: [ :selection | 
				self loadPreset: selection ] ];
		openModal
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> presetUrlFile [
	^ self golapDirectory / 'presetUrls.json'
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> query [

	^ usesRawQuery = true
		  ifTrue: [ queryPalettePresenter query ]
		  ifFalse: [ queryPresenter query ]
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> readPresetUrls [
	[ self presetUrlFile ensureCreateFile
		readStreamDo: [ :stream | ^ (NeoJSONReader on: stream) next ] ]
		on: Error
		do: [ :ex | ^ Array new ]
]

{ #category : 'operations' }
GolapNetworkClientPresenter >> recordHiDeHo [

	^ ([ GolapQueryJSONReaderWriter fromString: self query ]
		   on: Exception
		   do: [ :ex | ex return: nil ]) ifNotNil: [ :query |
		  queryPalettePresenter recordHiDeHo: query ]
]

{ #category : 'initialization' }
GolapNetworkClientPresenter >> resetQuery [

	queryPalettePresenter query: ''.
	queryPresenter ifNotNil: #resetQuery
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> retrieveConfig: aString field: anotherString ifError: errorBlock [
	[ | response |
	UIManager default
		informUserDuring: [ :bar | 
			bar label: anotherString , 'を取得中'.
			[ response := GolapHttpClient new
				url: self url;
				entity: (ZnEntity json: '{"retrieve":"' , aString , ',' , anotherString , '"}');
				timeout: self timeout;
				signalProgress: true;
				authenticateBlock: self authenticateBlock;
				post;
				response ]
				on: HTTPProgress
				do: [ :progress | 
					progress isEmpty
						ifFalse: [ bar current: progress percentage ].
					progress resume ] ].
	response isSuccess
		ifFalse: [ ^ errorBlock value ].
	^ response entity string lines copyWithoutFirst ]
		on: NetworkError , ZnParseError
		do: [ :ex | ^ errorBlock value ]
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> serverConfig [

	^ serverConfig ifNil: [
			  openButton ifNotNil: #disable.
			  self url asUrl authority ifNotNil: [
					  [
						  serverConfig := (GolapHttpClient
							                   post: self url
							                   data:
							                   (ZnEntity json: '{"control":"config"}')
							                   timeout: self timeout
							                   authenticateBlock: self authenticateBlock)
							                  in: [ :response |
									                  response code = 200 ifFalse: [ ^ nil ].
									                  response entity readStream in: [ :stream |
											                  | status |
											                  status := (stream upTo: Character lf)
												                            substrings: ':'.
											                  status size = 2 ifFalse: [ ^ nil ].
											                  status second trim = '0' ifFalse: [
												                  ^ nil ].
											                  openButton ifNotNil: #enable.
											                  (NeoJSONReader on: stream)
												                  mapClass: OrderedDictionary;
												                  next ] ] ]
						  on: NetworkError , ZnParseError
						  do: [ :ex | ^ nil ] ] ]
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> timeout [
	^ 3
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> transactionFields [
	^ self serverConfig
		ifNotNil: [ :config | 
			(((config at: 'traAttFile' ifAbsentPut: [ Dictionary new ])
				at: 'strFields'
				ifAbsent: [ String new ]) substrings: ',')
				,
					(((config at: 'traAttFile' ifAbsentPut: [ Dictionary new ])
						at: 'numFields'
						ifAbsent: [ String new ]) substrings: ',') ]
		ifNil: [ Array new ]
]

{ #category : 'private' }
GolapNetworkClientPresenter >> updateQueryHistoryPresenter [
]

{ #category : 'private' }
GolapNetworkClientPresenter >> updateServerConfig [
	fieldsAndValuesCache removeAll.
	serverConfigTree
		roots:
			([ (self
				flushServerConfig;
				serverConfig)
				ifNotNil: [ :config | 
					config keys asSortedCollection
						collect: [ :key | key -> (config at: key) ] ]
				ifNil: [ #() ] ]
				on: Error
				do: [ :ex | ex return: Array new ]).
	queryPresenter ifNotNil: #updateServerConfig
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> url [
	^ urlInput text asString
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> url: aString [
	urlInput text: aString
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> valuesAtField: aString [

	fieldsAndValuesCache
		at: aString
		ifPresent: [ :values | values ifNotEmpty: [ ^ values ] ].
	(self itemFields includes: aString) ifTrue: [ 
		^ fieldsAndValuesCache at: aString put: (self
				   retrieveConfig: 'GetItmAtt'
				   field: aString
				   ifError: [ ^ Array new ]) ].
	(self transactionFields includes: aString) ifTrue: [ 
		^ fieldsAndValuesCache at: aString put: (self
				   retrieveConfig: 'GetTraAtt'
				   field: aString
				   ifError: [ ^ Array new ]) ].
	^ Array new
]

{ #category : 'accessing' }
GolapNetworkClientPresenter >> writePreset: anArrayOfDictionary [
	self presetUrlFile ensureDelete
		writeStreamDo: [ :stream | ^ (NeoJSONWriter on: stream) nextPut: anArrayOfDictionary ]
]
