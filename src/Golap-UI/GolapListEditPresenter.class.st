Class {
	#name : 'GolapListEditPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'list',
		'addButton',
		'removeButton'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'layout' }
GolapListEditPresenter class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: #list;
		  add: (SpBoxLayout newHorizontal
				   add: #addButton width: self buttonHeight;
				   add: #removeButton width: self buttonHeight)
		  expand: false;
		  yourself
]

{ #category : 'api' }
GolapListEditPresenter >> addAction: aBlock [

	addButton action: aBlock
]

{ #category : 'accessing' }
GolapListEditPresenter >> addButton [

	^ addButton
]

{ #category : 'api' }
GolapListEditPresenter >> display: aBlock [

	list display: aBlock
]

{ #category : 'initialization' }
GolapListEditPresenter >> initializePresenters [

	super initializePresenters.
	list := self newList
		        whenSelectedItemChangedDo: [ self selectionChanged ];
		        yourself.
	addButton := self newButton
		             icon: (self iconNamed: #add);
		             yourself.
	removeButton := self newButton
		                icon: (self iconNamed: #remove);
		                disable;
		                yourself
]

{ #category : 'api' }
GolapListEditPresenter >> items [

	^ list items
]

{ #category : 'api' }
GolapListEditPresenter >> items: aCollection [

	list items: aCollection
]

{ #category : 'accessing' }
GolapListEditPresenter >> list [

	^ list
]

{ #category : 'api' }
GolapListEditPresenter >> removeAction: aBlock [

	removeButton action: aBlock
]

{ #category : 'accessing' }
GolapListEditPresenter >> removeButton [

	^ removeButton
]

{ #category : 'accessing' }
GolapListEditPresenter >> selectedItem [

	^ list selectedItem
]

{ #category : 'updating' }
GolapListEditPresenter >> selectionChanged [

	self updateButtons
]

{ #category : 'updating' }
GolapListEditPresenter >> updateButtons [

	list selectedItem
		ifNotNil: [ removeButton enable ]
		ifNil: [ removeButton disable ]
]
