Class {
	#name : #GolapQueryFunctionValuesPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'allValues',
		'availableValuesList',
		'selectedValuesList',
		'networkClient',
		'addToSelectionButton',
		'removeFromSelectionButton',
		'functionName'
	],
	#category : #'Golap-UI-StructuredEditor'
}

{ #category : #specs }
GolapQueryFunctionValuesPresenter class >> defaultSpec [
	<spec>
	^ SpBoxLayout newHorizontal
		add: #availableValuesList;
		add:
			(SpBoxLayout newVertical
				add: #addToSelectionButton;
				add: #removeFromSelectionButton;
				yourself)
			width: 30;
		add: #selectedValuesList;
		yourself
]

{ #category : #utilities }
GolapQueryFunctionValuesPresenter class >> on: aGolapNetworkClientPresenter functionName: aString openDialogIfAccepted: aBlock [
	| presenter |
	presenter := self new
		networkClient: aGolapNetworkClientPresenter;
		functionName: aString;
		yourself.
	presenter openDialogWithSpec okAction: [ aBlock cull: presenter ].
	^ presenter
]

{ #category : #operations }
GolapQueryFunctionValuesPresenter >> addToSelection [
	availableValuesList selectedItems
		ifNotEmpty: [ :items | 
			| newSelections |
			selectedValuesList
				unselectAll;
				items: (newSelections := selectedValuesList items , items).
			availableValuesList
				unselectAll;
				items: (allValues copyWithoutAll: newSelections) ]
]

{ #category : #accessing }
GolapQueryFunctionValuesPresenter >> field [
	^ self subclassResponsibility
]

{ #category : #accessing }
GolapQueryFunctionValuesPresenter >> functionName [
	^ functionName
]

{ #category : #accessing }
GolapQueryFunctionValuesPresenter >> functionName: aString [
	functionName := aString
]

{ #category : #initialization }
GolapQueryFunctionValuesPresenter >> initializePresenters [
	availableValuesList := self newList
		beMultipleSelection;
		yourself.
	selectedValuesList := self newList
		beMultipleSelection;
		yourself.
	addToSelectionButton := self newButton
		label: '→';
		action: [ self addToSelection ];
		yourself.
	removeFromSelectionButton := self newButton
		label: '←';
		action: [ self removeFromSelection ];
		yourself.
	self
		whenBuiltDo: [ :w | 
			| font |
			font := TextStyle defaultFont.
			w widget
				allMorphsDo: [ :m | 
					(m respondsTo: #font:)
						ifTrue: [ m font: font ] ] ]
]

{ #category : #initialization }
GolapQueryFunctionValuesPresenter >> initializeWindow: aWindowPresenter [
	aWindowPresenter title: (functionName ifNil: [ '' ])
]

{ #category : #accessing }
GolapQueryFunctionValuesPresenter >> networkClient [
	^ networkClient
]

{ #category : #accessing }
GolapQueryFunctionValuesPresenter >> networkClient: aGolapNetworkClientPresenter [
	networkClient := aGolapNetworkClientPresenter
]

{ #category : #operations }
GolapQueryFunctionValuesPresenter >> removeFromSelection [
	selectedValuesList selectedItems
		ifNotEmpty: [ :items | 
			| newSelections |
			selectedValuesList
				unselectAll;
				items: (newSelections := selectedValuesList items copyWithoutAll: items).
			availableValuesList
				unselectAll;
				items: (allValues copyWithoutAll: newSelections) ]
]

{ #category : #updating }
GolapQueryFunctionValuesPresenter >> resetValuesList [
	networkClient
		ifNotNil: [ availableValuesList
				items: (allValues := networkClient valuesAtField: self field) ].
	selectedValuesList items: Array new
]

{ #category : #accessing }
GolapQueryFunctionValuesPresenter >> selectedValues [
	^ selectedValuesList items
]
