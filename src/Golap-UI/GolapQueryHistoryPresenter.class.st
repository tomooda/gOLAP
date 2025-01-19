Class {
	#name : 'GolapQueryHistoryPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'queryStem',
		'queryHistory',
		'queryStemText',
		'queryHistoryList',
		'queryPreviewText'
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
				   positionOfSlider: 0.5;
				   add: (SpBoxLayout newVertical
						    add: '共通部分' expand: false;
						    add: #queryStemText);
				   add: (SpBoxLayout newVertical
						    add: '変化部分' expand: false;
						    add: #queryHistoryList;
						    yourself);
				   yourself);
		  add: (SpBoxLayout newVertical
				   add: 'プレビュー' expand: false;
				   add: #queryPreviewText;
				   yourself);
		  yourself
]

{ #category : 'initialization' }
GolapQueryHistoryPresenter >> initialize [

	super initialize.
	queryHistory := OrderedCollection new.
	queryStem := nil
]

{ #category : 'initialization' }
GolapQueryHistoryPresenter >> initializePresenters [

	super initializePresenters.
	queryStemText := self newText
		                 text: '';
		                 yourself.
	queryHistoryList := self newTable
		                    beResizable;
		                    showColumnHeaders;
		                    whenSelectedItemChangedDo: [
			                    self updateQueryPreviewText ];
		                    yourself.
	queryPreviewText := self newText
		                    text: '';
		                    yourself.
	self whenBuiltDo: [ self updatePresenters ]
]

{ #category : 'operations' }
GolapQueryHistoryPresenter >> recordHiDeHo: aHiDeSyntaxDictionary [

	queryStem := queryStem
		             ifNil: [ aHiDeSyntaxDictionary ]
		             ifNotNil: [
		             queryStem intersectionWith: aHiDeSyntaxDictionary ].
	queryHistory addLast: aHiDeSyntaxDictionary.
	self
		updateQueryStemText;
		updateQueryHistoryList;
		updateQueryPreviewText
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updatePresenters [

	self
		updateQueryStemText;
		updateQueryHistoryList;
		updateQueryPreviewText
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryHistoryList [

	(queryStem notNil and: [ queryHistory notEmpty ])
		ifTrue: [
			| done |
			done := queryStem syntaxAccessorsToTips asSet.
			queryHistoryList
				columns: (Array streamContents: [ :stream |
							 queryHistory do: [ :query |
									 query syntaxAccessorsToTipsDo: [ :accessor |
											 (done includes: accessor) ifFalse: [
													 done add: accessor.
													 stream nextPut:
															 (SpStringTableColumn
																  title: accessor printString
																  evaluated: [ :item |
																	  | value |
																	  value := accessor read: item.
																	  value isHiDeSyntaxTree
																		  ifTrue: [ '' ]
																		  ifFalse: [ value printString ] ]) ] ] ] ]);
				items: queryHistory ]
		ifFalse: [
			queryHistoryList
				columns: #(  );
				items: #(  ) ]
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryPreviewText [

	queryPreviewText text: (queryHistoryList selectedItem
			 ifNotNil: [ :query | STONJSON toStringPretty: query ]
			 ifNil: [ '' ])
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryStemText [

	queryStemText text: (queryStem
	ifNotNil: [ STONJSON toStringPretty: queryStem ]
	ifNil: [ '' ])
]
