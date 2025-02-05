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
		'thumbnailImage',
		'commentText',
		'cherrypickButton',
		'queryText',
		'useQueryStemButton',
		'importQueryButton'
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
				   positionOfSlider: 0.2;
				   add: (SpBoxLayout newVertical
						    add: '共通部分' expand: false;
						    add: #queryStemText;
						    add: #useQueryStemButton expand: false;
						    yourself);
				   add: (SpBoxLayout newVertical
						    add: (SpPanedLayout newVertical
								     add: (SpBoxLayout newVertical
										      add: '変化部分' expand: false;
										      add: #queryHistoryList;
										      yourself);
								     add: (SpPanedLayout newHorizontal
										      add: #thumbnailImage;
										      add: #commentText;
										      yourself);
								     yourself);
						    add: #cherrypickButton expand: false;
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
			         addColumn: (SpStringTableColumn
					          title: 'クエリ属性'
					          evaluated: [ :accessor | accessor printString ]);
			         addColumn: (SpStringTableColumn
					          title: '値'
					          evaluated: [ :accessor | accessor read: selectedQuery ]);
			         addColumn: ((SpCheckBoxTableColumn
					           title: '有効'
					           evaluated: [ :accessor |
						           enabledAccessors includes: accessor ])
					          onActivation: [ :accessor |
						          enabledAccessors add: accessor ];
					          onDeactivation: [ :accessor |
						          enabledAccessors remove: accessor ifAbsent: [  ] ];
					          yourself);
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
		                      action: [ self useQueryStem ];
		                      yourself.
	queryHistoryList := self newTable
		                    beResizable;
		                    showColumnHeaders;
		                    whenSelectedItemChangedDo: [
			                    self selectedQueryHistoryChanged ];
		                    yourself.
	thumbnailImage := self newImage
		                  autoScale: true;
		                  yourself.
	commentText := self newText.
	cherrypickButton := self newButton
		                    icon: (self iconNamed: #forward);
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
	queryHistory := queryStorage chronicle.
	self
		updateQueryStem;
		updateQueryStemText;
		updateQueryHistoryList;
		query: aHiDeSyntaxDictionary.
	^ queryRecord
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> selectedQueryHistoryChanged [

	self
		updateThumbnailImage;
		updateCommentText;
		updateButtons
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateButtons [

	cherrypickButton enabled:
		(queryHistoryList selectedItem notNil and: [
			 (queryHistoryList selectedItem query syntaxAccessorsToTips
				  copyWithoutAll: queryStem syntaxAccessorsToTips) notEmpty ]).
	importQueryButton enabled: importQueryBlock notNil
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateCommentText [

	commentText text:
		((queryHistoryList selectedItem ifNotNil: [ :record |
			  record comment ]) ifNil: [ '' ])
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updatePresenters [

	self
		updateQueryStemText;
		updateQueryHistoryList;
		updateButtons
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryHistoryList [

	queryStem notNil
		ifTrue: [
			| done |
			done := queryStem syntaxAccessorsToTips asSet.
			queryHistoryList
				columns: (Array streamContents: [ :stream |
							 queryHistory do: [ :queryRecord |
									 | query |
									 query := queryRecord query.
									 query syntaxAccessorsToTipsDo: [ :accessor |
											 (done includes: accessor) ifFalse: [
													 done add: accessor.
													 stream nextPut: ((SpStringTableColumn
																   title: accessor printString
																   evaluated: [ :record |
																	   ([ accessor read: record query ]
																		    on: Exception
																		    do: [ :ex | ex return: nil ])
																		   ifNotNil: [ :obj |
																			   obj isDictionary
																				   ifTrue: [
																					   GolapQueryJSONReaderWriter toStringPretty: obj ]
																				   ifFalse: [ obj printString ] ]
																		   ifNil: [ '' ] ])
																  isSortable: true;
																  yourself) ] ] ] ]);
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
GolapQueryHistoryPresenter >> updateThumbnailImage [

	thumbnailImage image:
		(queryHistoryList selectedItem ifNotNil: #thumbnail)
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
