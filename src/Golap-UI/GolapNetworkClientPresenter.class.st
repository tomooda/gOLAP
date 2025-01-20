Class {
	#name : 'GolapNetworkClientPresenter',
	#superclass : 'SpPresenter',
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
		'okButton',
		'usesRawQuery',
		'queryNotebook',
		'usesRawQueryText',
		'commentText',
		'queryHistoryPresenter'
	],
	#classInstVars : [
		'current'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'sole instance' }
GolapNetworkClientPresenter class >> current [
	^ current ifNil: [ current := self new ]
]

{ #category : 'layout' }
GolapNetworkClientPresenter class >> defaultLayout [

	<script: 'self new open'>
	<spec>
	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: #urlInput;
				   add: #presetUrlButton width: 20)
		  height: self inputTextHeight;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 0.8;
				   add: #queryNotebook;
				   add: (SpBoxLayout newVertical
						    add: 'サーバパラメータ' expand: false;
						    add: #serverConfigTree;
						    add: 'コメント' expand: false;
						    add: #commentText height: self inputTextHeight * 4;
						    yourself))
]

{ #category : 'sole instance' }
GolapNetworkClientPresenter class >> flushCurrent [
	<script: 'GolapNetworkClientPresenter flushCurrent'>
	current := nil
]

{ #category : 'utilities' }
GolapNetworkClientPresenter class >> openDialogIfAccepted: aBlock [
	<script: 'GolapNetworkClientPresenter openDialogIfAccepted: []'>
	^ self openDialogIfAccepted: aBlock ifCanceled: [  ]
]

{ #category : 'utilities' }
GolapNetworkClientPresenter class >> openDialogIfAccepted: aBlock ifCanceled: anotherBlock [

	^ self current
		  layout: self defaultLayout;
		  openDialogIfAccepted: aBlock ifCanceled: anotherBlock
]

{ #category : 'private' }
GolapNetworkClientPresenter >> asJSON [

	^ urlInput text asString trim
		  ifNotEmpty: [ :urlString |
			  | dict |
			  dict := Dictionary new
				          at: 'url' put: urlInput text asString trim;
				          yourself.
			  usesRawQuery = true
				  ifTrue: [ dict at: 'rawQuery' put: queryHistoryPresenter query ]
				  ifFalse: [
					  queryPresenter asJSON keysAndValuesDo: [ :key :value |
						  dict at: key put: value ] ].
			  dict ]
		  ifEmpty: [ nil ]
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
			 path: GolapModel coocurrenceDataDirectory absolutePath) ifNotNil: [
			:ref |
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

	queryHistoryPresenter query: queryPresenter queryDictionary
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
				            resetTransactionFilterSpec ];
		            yourself.
	presetUrlButton := self newButton
		                   icon: (Smalltalk ui icons iconNamed: #back);
		                   action: [ self openPresetUrlDialog ];
		                   yourself.
	queryPresenter := GolapQueryPresenter on: self.
	queryNotebook := self newNotebook
		                 addPage: (self newNotebookPage
				                  title: '基本';
				                  presenterProvider: [ queryPresenter ];
				                  whenRetrievedDo: [ usesRawQuery := false ];
				                  yourself);
		                 addPage: (self newNotebookPage
				                  title: '高度な条件';
				                  presenterProvider: [ queryHistoryPresenter ];
				                  whenRetrievedDo: [
					                  self updateQueryHistoryPresenter.
					                  self generateQueryText.
					                  usesRawQuery := true ];
				                  yourself);
		                 yourself.
	usesRawQueryText := false.
	queryHistoryPresenter := (self instantiate:
			                          GolapQueryHistoryPresenter)
		                         importQueryBlock: [ self generateQueryText ];
		                         yourself.
	serverConfigTree := self newTreeTable
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
		                    roots:
			                    (serverConfig ifNil: [ #(  ) ] ifNotNil: [
					                     serverConfig keys asSortedCollection
						                     collect: [ :key |
							                     key -> (serverConfig at: key) ] ]);
		                    yourself.
	commentText := self newText.
	self whenBuiltDo: [
		self window isDialog ifTrue: [
			okButton := self window buttons detect: [ :button |
				            button label = 'Ok' ].
			okButton enabled: false.
			self window buttons
				addFirst: (self newButton
						 label: 'Save';
						 action: [ self dumpToFile ];
						 yourself);
				addFirst: (self newButton
						 label: 'Reset';
						 action: [ self resetQuery ]) ].
		self updateServerConfig ].
	self focusOrder
		add: urlInput;
		add: serverConfigTree.
	self whenBuiltDo: [ :w |
		| font |
		font := TextStyle defaultFont.
		w widget allMorphsDo: [ :m |
			(m respondsTo: #font:) ifTrue: [ m font: font ] ] ]
]

{ #category : 'initialization' }
GolapNetworkClientPresenter >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		title: 'Connect to gOLAP server';
		initialExtent: self initialExtent
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
			queryHistoryPresenter query: string.
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
			self recordHiDeHo.
			[
			aBlock cull: (GolapApiClient
						 url: self url
						 query: self query
						 comment: self comment
						 serverConfig: self serverConfig
						 itemFieldQuerySpec: self itemFieldQuerySpec
						 authenticateBlock: self authenticateBlock) ] forkAt:
					Processor userBackgroundPriority ];
		cancelAction: anotherBlock
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
		  ifTrue: [ queryHistoryPresenter query ]
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

	([ GolapQueryJSONReader fromString: self query ]
		 on: Exception
		 do: [ :ex | ^ nil ]) ifNotNil: [ :query |
		queryHistoryPresenter recordHiDeHo: query ]
]

{ #category : 'initialization' }
GolapNetworkClientPresenter >> resetQuery [

	queryHistoryPresenter query: ''.
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
	^ serverConfig
		ifNil: [ okButton ifNotNil: #disable.
			self url asUrl authority
				ifNotNil: [ [ serverConfig := (GolapHttpClient
						post: self url
						data: (ZnEntity json: '{"control":"config"}')
						timeout: self timeout
						authenticateBlock: self authenticateBlock)
						in: [ :response | 
							response code = 200
								ifFalse: [ ^ nil ].
							response entity readStream
								in: [ :stream | 
									| status |
									status := (stream upTo: Character lf) substrings: ':'.
									status size = 2
										ifFalse: [ ^ nil ].
									status second trim = '0'
										ifFalse: [ ^ nil ].
									okButton ifNotNil: #enable.
									(NeoJSONReader on: stream)
										mapClass: OrderedDictionary;
										next ] ] ]
						on: NetworkError, ZnParseError
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
