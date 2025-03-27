Class {
	#name : 'GolapQueryHistoryPresenter',
	#superclass : 'SpPresenter',
	#traits : 'THiDeEditTags',
	#classTraits : 'THiDeEditTags classTrait',
	#instVars : [
		'queryStem',
		'queryStorage',
		'queryHistory',
		'queryStemText',
		'importQueryBlock',
		'queryHistoryList',
		'cherrypickButton',
		'queryText',
		'useQueryStemButton',
		'importQueryButton',
		'thumbnailButton',
		'commentButton',
		'tagList',
		'searchField',
		'tagButton',
		'narrativeDropList',
		'addToNarrativeButton',
		'removeFromNarrativeButton',
		'removeNarrativeButton',
		'addNarrativeButton',
		'historyLengthDropList'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'layout' }
GolapQueryHistoryPresenter class >> defaultLayout [

	^ SpPanedLayout newHorizontal
		  positionOfSlider: 0.7;
		  add: (SpBoxLayout newVertical
				   add: (SpBoxLayout newHorizontal
						    vAlignCenter;
						    add: 'フィード  ' expand: false;
						    add: #narrativeDropList width: 300;
						    add: #addNarrativeButton width: self buttonHeight;
						    add: #removeNarrativeButton width: self buttonHeight;
						    yourself)
				   expand: false;
				   add: (SpPanedLayout newVertical
						    positionOfSlider: 0.4;
						    add: (SpPanedLayout newHorizontal
								     add: (SpBoxLayout newVertical
										      add: '共通部分' expand: false;
										      add: #queryStemText;
										      add: #useQueryStemButton expand: false;
										      yourself);
								     add: (SpBoxLayout newVertical
										      add: 'タグ' expand: false;
										      add: #tagList;
										      add: (SpBoxLayout newHorizontal
												       add: '検索' asPresenter expand: false;
												       add: #searchField;
												       yourself)
										      expand: false;
										      yourself);
								     yourself);
						    add: (SpBoxLayout newVertical
								     add: (SpBoxLayout newHorizontal
										      add: '変化部分' expand: false;
										      add: (SpBoxLayout newHorizontal
												       hAlignEnd;
												       vAlignEnd;
												       add: '表示件数' asPresenter expand: false;
												       add: #historyLengthDropList expand: false);
										      yourself)
								     expand: false;
								     add: #queryHistoryList;
								     add: (SpBoxLayout newHorizontal
										      add: #thumbnailButton;
										      add: #commentButton;
										      add: #tagButton;
										      add: #addToNarrativeButton;
										      add: #removeFromNarrativeButton;
										      add: #cherrypickButton;
										      yourself)
								     expand: false;
								     yourself);
						    yourself);
				   yourself);
		  add: (SpBoxLayout newVertical
				   add: 'クエリ' expand: false;
				   add: #queryText;
				   add: #importQueryButton expand: false;
				   yourself);
		  yourself
]

{ #category : 'utilities' }
GolapQueryHistoryPresenter class >> golapDirectory [

	^ Golap golapDirectory
]

{ #category : 'columns' }
GolapQueryHistoryPresenter >> accessorColumn: accessor [

	^ (SpStringTableColumn
		   title: accessor printString
		   evaluated: [ :record |
			   ([ accessor read: record query ]
				    on: Exception
				    do: [ :ex | ex return: nil ])
				   ifNotNil: [ :obj |
					   obj isDictionary
						   ifTrue: [ GolapQueryJSONReaderWriter toStringPretty: obj ]
						   ifFalse: [ obj printString ] ]
				   ifNil: [ '' ] ])
		  beSortable;
		  yourself
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> addToNarrative [

	^ self addToNarrativeMenu ifNotNil: #openWithSpecAtPointer
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> addToNarrativeMenu [

	| currentNarrative |
	currentNarrative := self
		                    selectedNarrativeDo: #yourself
		                    ifChronicleDo: [ nil ].
	queryHistoryList selectedItems ifNotEmpty: [ :queryRecords |
		^ self newMenu
			  addGroup: [ :group |
				  queryStorage narratives do: [ :narrative |
						  currentNarrative = narrative ifFalse: [
								  group addItem: [ :item |
										  item
											  icon: (self iconNamed: #forward);
											  name: narrative name;
											  action: [ narrative addAll: queryRecords ] ] ] ] ];
			  addGroup: [ :group |
				  group addItem: [ :item |
					  item
						  name: '新規フィード...';
						  icon: (self iconNamed: #add);
						  action: [
							  self createNewNarrativeDo: [ :narrative |
									  narrative addAll: queryRecords.
									  self updateQueryHistory ] ] ] ] ].
	^ nil
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> cherrypick [

	queryHistoryList selectedItem ifNotNil: [ :selectedQueryRecord |
		self cherrypick: selectedQueryRecord ]
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> cherrypick: selectedQueryRecord [

	| selectedQuery enabledAccessors table |
	selectedQuery := selectedQueryRecord query.
	enabledAccessors := (selectedQuery syntaxAccessorsToTips
		                     copyWithoutAll: queryStem syntaxAccessorsToTips)
		                    asSet.
	table := self newTable
		         beSingleSelection;
		         beResizable;
		         addColumn: ((SpCheckBoxTableColumn
				           title: '有効'
				           evaluated: [ :accessor |
					           enabledAccessors includes: accessor ])
				          onActivation: [ :accessor |
					          enabledAccessors add: accessor ];
				          onDeactivation: [ :accessor |
					          enabledAccessors remove: accessor ifAbsent: [  ] ];
				          beNotExpandable;
				          yourself);
		         addColumn: ((SpStringTableColumn
				           title: 'クエリ属性'
				           evaluated: [ :accessor | accessor printString ])
				          beNotExpandable;
				          yourself);
		         addColumn: (SpStringTableColumn
				          title: '値'
				          evaluated: [ :accessor | accessor read: selectedQuery ]);
		         items:
			         (selectedQuery syntaxAccessorsToTips copyWithoutAll:
				          queryStem syntaxAccessorsToTips);
		         yourself.
	table asModalWindow
		title: '上書きする属性を選択してください';
		okAction: [
			([ GolapQueryJSONReaderWriter fromString: queryText text ]
				 on: Error
				 do: [ :ex | ex return: nil ])
				ifNotNil: [ :query |
					enabledAccessors do: [ :accessor |
							| value |
							value := accessor read: selectedQuery.
							[ accessor write: value to: query ]
								on: HiDeSyntaxDictionaryKeyNotFound
								do: [ :ex |
									ex resume: (ex signaler at: ex key put: query class new) ] ].
					queryText text:
							(GolapQueryJSONReaderWriter toStringPretty: query) ]
				ifNil: [
					UIManager default alert: '上書き前のクエリが不正です。' title: 'クエリ構文エラー' ] ];
		open
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> createNewNarrative [

	self createNewNarrativeDo: [  ]
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> createNewNarrativeDo: aBlock [

	[
	(UIManager default
		 request: '新規フィード名'
		 initialAnswer: '新フィード'
		 title: 'gOLAP クエリフィード管理') ifNil: [ ^ self ] ifNotNil: [ :name |
		(queryStorage hasNarrativeNamed: name) ifFalse: [
			| id narrative result |
			id := (narrative := queryStorage newNarrativeNamed: name) identity.
			self updateNarrativeDropList: narrative.
			narrativeDropList selectItem: (narrativeDropList items
					 detect: [ :assoc | assoc value = id ]
					 ifNone: [ narrativeDropList items first ]).
			self updateQueryHistory.
			result := aBlock cull: narrative.
			self updateNarrativeDropList: narrative.
			^ result ].
		UIManager default alert: '既に使われているフィード名です' title: 'gOLAPクエリフィード管理' ] ]
		repeat
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> editComment [

	queryHistoryList selectedItem ifNotNil: [ :record |
		| text |
		record hideLoad.
		text := self newText text: (record comment ifNil: [ '' ]).
		text openDialog
			title: 'コメント';
			okAction: [
				| newComment |
				newComment := text text asString trim ifEmpty: [ nil ].
				newComment ~= record comment ifTrue: [
						record
							comment: newComment;
							hideSave.
						self updateQueryHistoryList ] ] ]
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> editTags [

	queryHistoryList selectedItem ifNotNil: [ :chronicleModel |
		self
			editTags: tagList items
			on: chronicleModel
			title: 'タグ編集'
			createNewTagTitle: '新規タグ作成'
			okAction: [ self updateQueryHistory ] ]
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> importQuery [

	importQueryBlock ifNotNil: [ importQueryBlock value ]
]

{ #category : 'accessing' }
GolapQueryHistoryPresenter >> importQueryBlock: aBlock [

	importQueryBlock := aBlock.
	self updateButtons
]

{ #category : 'initialization' }
GolapQueryHistoryPresenter >> initialize [

	super initialize.
	queryStorage := GolapQueryStorage on:
		                self class golapDirectory / 'Queries'.
	self updateNarrativeDropList
]

{ #category : 'initialization' }
GolapQueryHistoryPresenter >> initializePresenters [

	super initializePresenters.
	narrativeDropList := self newDropList
		                     display: [ :assoc | assoc key asString ];
		                     displayIcon: [ :assoc |
			                     assoc value = #newNarrative
				                     ifTrue: [ self iconNamed: #add ]
				                     ifFalse: [ nil ] ];
		                     items: {  };
		                     startWithSelection;
		                     whenSelectedItemChangedDo: [
			                     self selectedNarrativeChanged ];
		                     yourself.
	addNarrativeButton := self newButton
		                      icon: (self iconNamed: #add);
		                      action: [ self createNewNarrative ];
		                      yourself.
	removeNarrativeButton := self newButton
		                         icon: (self iconNamed: #remove);
		                         action: [ self removeNarrative ];
		                         yourself.
	queryStemText := self newText
		                 text: '';
		                 yourself.
	useQueryStemButton := self newButton
		                      icon: (self iconNamed: #forward);
		                      label: 'クエリに上書き';
		                      action: [ self useQueryStem ];
		                      yourself.
	tagList := (self instantiate: HiDeTagFilterPresenter)
		           tagColumnTitle: 'タグ';
		           quantityColumnTitle: 'クエリ数';
		           whenFilterChangedDo: [ self updateQueryHistory ];
		           yourself.
	searchField := self newTextInput whenSubmitDo: [ :s |
		               self searchFieldChanged ].
	historyLengthDropList := self newDropList
		                         display: [ :assoc | assoc key ];
		                         items: {
				                         ('~100' -> 100).
				                         ('~1,000' -> 1000).
				                         ('全て' -> nil) };
		                         startWithSelection;
		                         whenSelectedItemChangedDo: [
			                         self updateQueryHistoryList ];
		                         yourself.
	queryHistoryList := self newTable
		                    beMultipleSelection;
		                    beResizable;
		                    dragEnabled: true;
		                    showColumnHeaders;
		                    whenSelectedItemChangedDo: [
			                    self selectedQueryHistoryChanged ];
		                    yourself.
	thumbnailButton := self newButton
		                   icon: (self iconNamed: #objects);
		                   label: 'グラフ';
		                   action: [ self showThumbnail ];
		                   yourself.
	commentButton := self newButton
		                 icon: (self iconNamed: #announcement);
		                 label: 'コメント';
		                 action: [ self editComment ];
		                 yourself.
	tagButton := self newButton
		             icon: self tagIcon;
		             label: 'タグ編集';
		             action: [ self editTags ];
		             disable;
		             yourself.
	addToNarrativeButton := self newButton
		                        iconName: #publish;
		                        label: '他フィードに共有';
		                        action: [ self addToNarrative ];
		                        yourself.
	removeFromNarrativeButton := self newButton
		                             icon: (self iconNamed: #remove);
		                             label: 'このフィードから削除';
		                             action: [ self removeFromNarrative ];
		                             yourself.
	cherrypickButton := self newButton
		                    icon: (self iconNamed: #forward);
		                    label: 'クエリに注入';
		                    action: [ self cherrypick ];
		                    yourself.
	queryText := self newText
		             text: '';
		             dropEnabled: true;
		             wantsDrop: [ :transfer |
			             transfer passenger allSatisfy: [ :obj |
					             obj isKindOf: GolapQueryRecord ] ];
		             acceptDrop: [ :transfer |
			             transfer passenger ifNotEmpty: [ :queryRecords |
					             self cherrypick: queryRecords first ] ];
		             contextMenu: [ self queryTextMenu ];
		             yourself.
	importQueryButton := self newButton
		                     icon: (self iconNamed: #down);
		                     label: '基本クエリからコピー';
		                     action: [ self importQuery ];
		                     yourself.
	self whenBuiltDo: [ self updatePresenters ]
]

{ #category : 'testing' }
GolapQueryHistoryPresenter >> narrativeSelected [

	^ (narrativeDropList ifNotNil: [
		   narrativeDropList selectedItem value ]) notNil
]

{ #category : 'accessing' }
GolapQueryHistoryPresenter >> query [

	^ queryText text asString trim
]

{ #category : 'accessing' }
GolapQueryHistoryPresenter >> query: aStringOrDictionary [

	queryText text: (aStringOrDictionary ifNil: [ '' ] ifNotNil: [
			 aStringOrDictionary isString
				 ifTrue: [ aStringOrDictionary ]
				 ifFalse: [
				 GolapQueryJSONReaderWriter toStringPretty: aStringOrDictionary ] ])
]

{ #category : 'menus' }
GolapQueryHistoryPresenter >> queryTextMenu [

	^ self newMenu
		  addGroup: [ :menuGroup |
			  menuGroup addItem: [ :menuItem |
					  menuItem
						  name: '基本クエリからコピー';
						  action: [ self importQuery ] ] ];
		  yourself
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> recordHiDeHo: aHiDeSyntaxDictionary [

	| queryRecord |
	queryRecord := GolapQueryRecord new
		               url: queryStorage url;
		               query: aHiDeSyntaxDictionary;
		               yourself.
	queryStorage chronicleSave: queryRecord.
	self
		updateQueryHistory;
		query: aHiDeSyntaxDictionary.
	^ queryRecord
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> removeFromNarrative [

	queryHistoryList selectedItem ifNotNil: [ :selectedQueryRecord |
		self
			selectedNarrativeDo: [ :narrative |
				narrative remove: selectedQueryRecord.
				self updateQueryHistory ]
			ifChronicleDo: [ nil ] ]
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> removeNarrative [

	self
		selectedNarrativeDo: [ :narrative |
			(UIManager default
				 confirm: 'フィード ' , narrative name , ' を削除しますか？'
				 label: 'gOLAPクエリフィード管理') ifTrue: [
				queryStorage removeNarrative: narrative.
				self updateNarrativeDropList: nil ] ]
		ifChronicleDo: [  ]
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> searchFieldChanged [

	self updateQueryHistory
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> selectedNarrativeChanged [

	narrativeDropList selectedItem ifNotNil: [ :assoc |
		assoc value = #newNarrative ifTrue: [ ^ self createNewNarrative ] ].
	removeNarrativeButton enabled: self narrativeSelected.
	self updateQueryHistory
]

{ #category : 'accessing' }
GolapQueryHistoryPresenter >> selectedNarrativeDo: narrativeBlock ifChronicleDo: chronicleBlock [

	^ (narrativeDropList ifNotNil: [
		   narrativeDropList selectedItem value ])
		  ifNotNil: [ :narrativeId |
			  narrativeBlock value: (queryStorage narrativeAt: narrativeId) ]
		  ifNil: chronicleBlock
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> selectedQueryHistoryChanged [

	self updateButtons
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> showThumbnail [

	queryHistoryList selectedItem ifNotNil: [ :record |
		record hideLoad.
		record thumbnail ifNotNil: [ :thumbnail |
			| image |
			image := thumbnail asPresenter.
			image autoScale: true.
			image openDialog title: 'グラフ' ] ]
]

{ #category : 'icons' }
GolapQueryHistoryPresenter >> tagIcon [

	| form fillColor a |
	fillColor := Color white.
	form := Form extent: 24 @ 24 depth: 32.
	a := 8.
	form getCanvas
		drawPolygon: {
				(4 @ 4).
				(4 + a @ 4).
				(23 @ (23 - a)).
				(23 - a @ 23).
				4 @ (a + 4) }
		color: Color white
		borderWidth: 1
		borderColor: Color black;
		flush.
	^ form
]

{ #category : 'columns' }
GolapQueryHistoryPresenter >> timestampColumn [

	^ (SpStringTableColumn title: 'タイムスタンプ' evaluated: [ :record |
			   | timestamp |
			   timestamp := record hideMetadata timestamp.
			   String streamContents: [ :stream |
					   timestamp year printOn: stream base: 10 nDigits: 4.
					   stream nextPut: $/.
					   timestamp month printOn: stream base: 10 nDigits: 2.
					   stream nextPut: $/.
					   timestamp dayOfMonth printOn: stream base: 10 nDigits: 2.
					   stream space.
					   timestamp hour printOn: stream base: 10 nDigits: 2.
					   stream nextPut: $:.
					   timestamp minute printOn: stream base: 10 nDigits: 2.
					   stream nextPut: $:.
					   timestamp second printOn: stream base: 10 nDigits: 2 ] ])
		  beSortable;
		  yourself
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateButtons [

	queryHistoryList selectedItem
		ifNotNil: [ :record |
			{
				thumbnailButton.
				commentButton.
				tagButton.
				addToNarrativeButton } do: #enable.
			self
				selectedNarrativeDo: [ :narrative |
				removeFromNarrativeButton enable ]
				ifChronicleDo: [ removeFromNarrativeButton disable ].
			cherrypickButton enabled:
				(record query syntaxAccessorsToTips copyWithoutAll:
					 queryStem syntaxAccessorsToTips) notEmpty ]
		ifNil: [
			{
				thumbnailButton.
				commentButton.
				tagButton.
				addToNarrativeButton.
				removeFromNarrativeButton.
				cherrypickButton } do: #disable ].
	importQueryButton enabled: importQueryBlock notNil.
	removeNarrativeButton enabled: self narrativeSelected
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateNarrativeDropList [

	self updateNarrativeDropList: narrativeDropList selectedItem
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateNarrativeDropList: aHiDeNarrative [

	| selection |
	selection := nil.
	narrativeDropList items: { ('全クエリ' -> nil) }
		, (queryStorage narratives collect: [ :narrative |
				 | item |
				 item := narrative name -> narrative identity.
				 narrative = aHiDeNarrative ifTrue: [ selection := item ].
				 item ]).
	selection
		ifNotNil: [ narrativeDropList selectItem: selection ]
		ifNil: [ narrativeDropList selectIndex: 1 ]
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updatePresenters [

	self
		updateQueryHistory;
		updateButtons
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryHistory [

	| records |
	self
		selectedNarrativeDo: [ :narrative |
			records := narrative asArray.
			self updateTags: queryStorage chronicle ]
		ifChronicleDo: [
			records := queryStorage chronicle.
			self updateTags: records ].

	records := records select: tagList.
	searchField text asString trim ifNotEmpty: [ :str |
		records := records select: [ :m | m includesSubstring: str ] ].
	queryHistory := records.
	self
		updateQueryStem;
		updateQueryStemText;
		updateQueryHistoryList
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryHistoryList [

	queryStem notNil
		ifTrue: [
			| done items |
			done := queryStem syntaxAccessorsToTips asSet.
			items := (historyLengthDropList selectedItem ifNotNil: #value)
				         ifNotNil: [ :limit |
					         queryHistory
						         copyFrom: 1
						         to: (limit min: queryHistory size) ]
				         ifNil: [ queryHistory ].
			queryHistoryList
				columns: (Array streamContents: [ :stream |
							 stream nextPut: self timestampColumn.
							 queryHistory do: [ :queryRecord |
									 | query |
									 query := queryRecord query.
									 query syntaxAccessorsToTipsDo: [ :accessor |
											 (done includes: accessor) ifFalse: [
													 done add: accessor.
													 stream nextPut: (self accessorColumn: accessor) ] ] ] ]);
				items: (queryHistoryList columns
						 ifEmpty: [ #(  ) ]
						 ifNotEmpty: [ items ]) ]
		ifFalse: [
			queryHistoryList
				columns: #(  );
				items: #(  ) ]
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryStem [

	queryStem := queryHistory
		             ifNotEmpty: [
			             queryHistory
				             inject: queryHistory first query
				             into: [ :stem :record |
				             stem intersectionWith: record query ] ]
		             ifEmpty: [ nil ]
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryStemText [

	queryStemText text: (queryStem
			 ifNotNil: [ GolapQueryJSONReaderWriter toStringPretty: queryStem ]
			 ifNil: [ '' ])
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateTags: aCollectionOfQueryRecord [

	tagList persistencies: aCollectionOfQueryRecord
]

{ #category : 'accessing' }
GolapQueryHistoryPresenter >> url: aString [

	queryStorage url = aString ifTrue: [ ^ self ].
	queryStorage url: aString.
	queryHistory := queryStorage chronicle.
	self
		updateQueryStem;
		updateQueryStemText;
		updateQueryHistoryList.
	queryHistory ifNotEmpty: [ self query: queryHistory last query ]
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> useQueryStem [

	self query: queryStem
]
