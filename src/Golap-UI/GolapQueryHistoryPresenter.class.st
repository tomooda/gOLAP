Class {
	#name : 'GolapQueryHistoryPresenter',
	#superclass : 'SpPresenter',
	#traits : 'THiDeEditTags',
	#classTraits : 'THiDeEditTags classTrait',
	#instVars : [
		'queryStorage',
		'queryHistoryList',
		'tagList',
		'searchField',
		'tagButton',
		'narrativeDropList',
		'addToNarrativeButton',
		'removeFromNarrativeButton',
		'removeNarrativeButton',
		'addNarrativeButton',
		'historyLengthDropList',
		'thumbnailImage',
		'commentText',
		'queryText'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

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
									  self updateQueryHistoryList ] ] ] ] ].
	^ nil
]

{ #category : 'accessing' }
GolapQueryHistoryPresenter >> buttonHeight [

	^ self class buttonHeight
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
			self updateQueryHistoryList.
			result := aBlock cull: narrative.
			self updateNarrativeDropList: narrative.
			^ result ].
		UIManager default alert: '既に使われているフィード名です' title: 'gOLAPクエリフィード管理' ] ]
		repeat
]

{ #category : 'layout' }
GolapQueryHistoryPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: 'フィード  ' expand: false;
				   add: narrativeDropList width: 300;
				   add: addNarrativeButton width: self buttonHeight;
				   add: removeNarrativeButton width: self buttonHeight;
				   yourself)
		  expand: false;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 0.6;
				   add: (SpPanedLayout newVertical
						    positionOfSlider: 0.3;
						    add: (SpBoxLayout newVertical
								     add: 'タグ' expand: false;
								     add: tagList;
								     add: (SpBoxLayout newHorizontal
										      add: '検索' asPresenter expand: false;
										      add: searchField;
										      yourself)
								     expand: false;
								     yourself);
						    add: (SpBoxLayout newVertical
								     add: (SpBoxLayout newHorizontal
										      add: '履歴' expand: false;
										      add: (SpBoxLayout newHorizontal
												       hAlignEnd;
												       vAlignEnd;
												       add: '表示件数' asPresenter expand: false;
												       add: historyLengthDropList expand: false);
										      yourself)
								     expand: false;
								     add: queryHistoryList;
								     add: (SpBoxLayout newHorizontal
										      add: tagButton;
										      add: addToNarrativeButton;
										      add: removeFromNarrativeButton;
										      yourself)
								     expand: false;
								     yourself);
						    yourself);
				   add: (SpBoxLayout newVertical
						    add: 'クエリ' expand: false;
						    add: queryText expand: true;
						    add: 'グラフ' expand: false;
						    add: thumbnailImage height: 256;
						    add: 'コメント' expand: false;
						    add: commentText height: self buttonHeight * 3;
						    yourself);
				   yourself);
		  yourself
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
			okAction: [ self updateQueryHistoryList ] ]
]

{ #category : 'accessing' }
GolapQueryHistoryPresenter >> historyRecord [

	^ queryHistoryList selectedItem
]

{ #category : 'initialization' }
GolapQueryHistoryPresenter >> initialize [

	super initialize.
	queryStorage := GolapQueryStorage forQuery.
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
	queryText := self newText
		             text: '';
		             yourself.
	tagList := (self instantiate: HiDeTagFilterPresenter)
		           tagColumnTitle: 'タグ';
		           quantityColumnTitle: 'クエリ数';
		           whenFilterChangedDo: [ self updateQueryHistoryList ];
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
		                    showColumnHeaders;
		                    addColumn: (SpStringTableColumn
				                     title: 'タイムスタンプ'
				                     evaluated: [ :record |
					                     record timestampString ]);
		                    addColumn:
			                    (SpStringTableColumn
				                     title: 'URL'
				                     evaluated: [ :record | record url ]);
		                    addColumn: (SpStringTableColumn
				                     title: 'コメント'
				                     evaluated: [ :record | record comment ]);
		                    whenSelectedItemChangedDo: [
			                    self selectedQueryHistoryChanged ];
		                    yourself.
	thumbnailImage := self newImage
		                  autoScale: false;
		                  color: Color white;
		                  whenBuiltDo: [
			                  thumbnailImage withAdapterDo: [ :a |
					                  a widgetDo: [ :w | w color: Color white ] ] ];
		                  yourself.
	commentText := self newText
		               text: '';
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
	self whenBuiltDo: [ self updatePresenters ]
]

{ #category : 'testing' }
GolapQueryHistoryPresenter >> narrativeSelected [

	^ (narrativeDropList ifNotNil: [
		   narrativeDropList selectedItem value ]) notNil
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> removeFromNarrative [

	queryHistoryList selectedItem ifNotNil: [ :selectedQueryRecord |
		self
			selectedNarrativeDo: [ :narrative |
				narrative remove: selectedQueryRecord.
				self updateQueryHistoryList ]
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

	self updateQueryHistoryList
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> selectedNarrativeChanged [

	narrativeDropList selectedItem ifNotNil: [ :assoc |
		assoc value = #newNarrative ifTrue: [ ^ self createNewNarrative ] ].
	removeNarrativeButton enabled: self narrativeSelected.
	self updateQueryHistoryList
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

	self
		updateQueryText;
		updateThumbnailImage;
		updateCommentText;
		updateButtons
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
				tagButton.
				addToNarrativeButton } do: #enable.
			self
				selectedNarrativeDo: [ :narrative |
				removeFromNarrativeButton enable ]
				ifChronicleDo: [ removeFromNarrativeButton disable ] ]
		ifNil: [
			{
				tagButton.
				addToNarrativeButton.
				removeFromNarrativeButton } do: #disable ].
	removeNarrativeButton enabled: self narrativeSelected
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateCommentText [

	commentText text:
		((self historyRecord ifNotNil: #comment) ifNil: [ '' ])
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
		updateQueryHistoryList;
		updateButtons
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryHistoryList [

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
	queryHistoryList items: records
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryText [

	queryText text: (self historyRecord
			 ifNotNil: [ :record | STONJSON toStringPretty: record query ]
			 ifNil: [ '' ])
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateTags: aCollectionOfQueryRecord [

	tagList persistencies: aCollectionOfQueryRecord
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateThumbnailImage [

	thumbnailImage image: (self historyRecord ifNotNil: #thumbnail)
]

{ #category : 'accessing' }
GolapQueryHistoryPresenter >> url: aString [

	queryStorage url = aString ifTrue: [ ^ self ].
	queryStorage url: aString.
	self updateQueryHistoryList
]
