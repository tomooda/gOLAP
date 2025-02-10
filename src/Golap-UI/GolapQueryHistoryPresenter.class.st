Class {
	#name : 'GolapQueryHistoryPresenter',
	#superclass : 'SpPresenter',
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
		'requiredTags',
		'tagHistogram',
		'tagButton'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'layout' }
GolapQueryHistoryPresenter class >> defaultLayout [

	^ SpPanedLayout newHorizontal
		  positionOfSlider: 0.5;
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
						    add: '変化部分' expand: false;
						    add: #queryHistoryList;
						    add: (SpBoxLayout newHorizontal
								     add: #thumbnailButton;
								     add: #commentButton;
								     add: #tagButton;
								     add: #cherrypickButton;
								     yourself)
						    expand: false;
						    yourself));
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
GolapQueryHistoryPresenter >> cherrypick [

	queryHistoryList selectedItem ifNotNil: [ :selectedQueryRecord |
		| selectedQuery enabledAccessors table |
		selectedQuery := selectedQueryRecord query.
		enabledAccessors := (selectedQuery syntaxAccessorsToTips
			                     copyWithoutAll:
			                     queryStem syntaxAccessorsToTips) asSet.
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
		table openDialog
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
						UIManager default alert: '上書き前のクエリが不正です。' title: 'クエリ構文エラー' ] ] ]
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
		| listEditor |
		listEditor := GolapListEditPresenter new.
		listEditor
			items: chronicleModel tags;
			addAction: [
				| menu |
				menu := listEditor newMenu.
				(tagHistogram asSet asArray copyWithoutAll: listEditor items)
					asSortedCollection do: [ :tag |
						menu addItem: [ :item |
								item
									name: tag;
									action: [
										listEditor items: (listEditor items asSortedCollection
													 add: tag;
													 yourself) ] ] ].
				menu addItem: [ :item |
					item
						name: '新規タグ作成...';
						action: [
							(UIManager default request: '新規タグ作成') ifNotNil: [ :tag |
									listEditor items: (listEditor items asSortedCollection
												 add: tag trim;
												 yourself) ] ] ].
				menu openWithSpecAtPointer ];
			removeAction: [
				listEditor items:
					(listEditor items copyWithout: listEditor selectedItem) ].
		listEditor openDialog
			title: 'タグ編集';
			okAction: [
				chronicleModel tags: listEditor items.
				chronicleModel hideSave.
				self updateQueryHistory ] ]
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

	tagHistogram := Bag new.
	requiredTags := Set new.
	super initialize.
	queryStorage := GolapQueryStorage new basepath:
		                self class golapDirectory / 'Queries'.
	queryStorage
		loadSettings;
		loadChronicle.
	queryHistory := queryStorage chronicle.
	self updateQueryStem
]

{ #category : 'initialization' }
GolapQueryHistoryPresenter >> initializePresenters [

	super initializePresenters.
	queryStemText := self newText
		                 text: '';
		                 yourself.
	useQueryStemButton := self newButton
		                      icon: (self iconNamed: #forward);
		                      label: 'クエリに上書き';
		                      action: [ self useQueryStem ];
		                      yourself.
	tagList := self newTable
		           beResizable;
		           addColumn: ((SpCheckBoxTableColumn
				             title: ''
				             evaluated: [ :tag | requiredTags includes: tag ])
				            onActivation: [ :tag |
					            requiredTags add: tag.
					            self updateQueryHistory ];
				            onDeactivation: [ :tag |
					            requiredTags remove: tag ifAbsent: [  ].
					            self updateQueryHistory ];
				            beNotExpandable;
				            yourself);
		           addColumn:
		           (SpStringTableColumn
			            title: 'タグ'
			            evaluated: [ :tag | tag ]) beSortable;
		           addColumn: ((SpStringTableColumn
				             title: 'クエリ数'
				             evaluated: [ :tag |
					             (tagHistogram occurrencesOf: tag) asString ])
				            width: 80;
				            beSortable;
				            sortFunction:
					            [ :tag | tagHistogram occurrencesOf: tag ] ascending;
				            yourself);
		           yourself.
	searchField := self newTextInput whenSubmitDo: [ :s |
		               self searchFieldChanged ].
	queryHistoryList := self newTable
		                    beResizable;
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
	cherrypickButton := self newButton
		                    icon: (self iconNamed: #forward);
		                    label: 'クエリに注入';
		                    action: [ self cherrypick ];
		                    yourself.
	queryText := self newText
		             text: '';
		             contextMenu: [ self queryTextMenu ];
		             yourself.
	importQueryButton := self newButton
		                     label: '基本クエリから';
		                     action: [ self importQuery ];
		                     yourself.
	self whenBuiltDo: [ self updatePresenters ]
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
	queryStorage chronicleAdd: queryRecord.
	self
		updateQueryHistory;
		query: aHiDeSyntaxDictionary.
	^ queryRecord
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> searchFieldChanged [

	self updateQueryHistory
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
				tagButton } do: #enable.
			cherrypickButton enabled:
				(record query syntaxAccessorsToTips copyWithoutAll:
					 queryStem syntaxAccessorsToTips) notEmpty ]
		ifNil: [
			{
				thumbnailButton.
				commentButton.
				tagButton.
				cherrypickButton } do: #disable ].
	importQueryButton enabled: importQueryBlock notNil
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
	records := queryStorage chronicle.
	self updateTags: records.
	requiredTags do: [ :tag |
		records := records select: [ :m | m hasTag: tag ] ].
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
			| done |
			done := queryStem syntaxAccessorsToTips asSet.
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
						 ifNotEmpty: [ queryHistory ]) ]
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

	tagHistogram := aCollectionOfQueryRecord
		                inject: Bag new
		                into: [ :tags :chronicleModel |
			                tags
				                addAll: chronicleModel tags;
				                yourself ].
	requiredTags := requiredTags select: [ :tag |
		                tagHistogram includes: tag ].
	tagList items: tagHistogram asSet asSortedCollection
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
