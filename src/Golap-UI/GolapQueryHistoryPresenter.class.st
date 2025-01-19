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
	queryHistoryList := self newList
		                    display: #key;
		                    whenSelectedItemChangedDo: [
			                    self updateQueryPreviewText ];
		                    yourself.
	queryPreviewText := self newText
		                    text: '';
		                    yourself.
	self whenBuiltDo: [
		self
			updateQueryStemText;
			updateQueryHistoryList;
			updateQueryPreviewText ]
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
GolapQueryHistoryPresenter >> updateQueryHistoryList [

	queryHistoryList items: (queryStem
			 ifNotNil: [
				 queryHistory collect: [ :query |
					 (', ' join:
						  ((query \ queryStem) syntaxAccessorsToTips collect:
							   #printString)) -> query ] ]
			 ifNil: [ Array new ])
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryPreviewText [

	queryPreviewText text: (queryHistoryList selectedItem
			 ifNotNil: [ :assoc | STONJSON toStringPretty: assoc value ]
			 ifNil: [ '' ])
]

{ #category : 'updating' }
GolapQueryHistoryPresenter >> updateQueryStemText [

	queryStemText text: (queryStem
	ifNotNil: [ STONJSON toStringPretty: queryStem ]
	ifNil: [ '' ])
]
