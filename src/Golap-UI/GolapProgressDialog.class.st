Class {
	#name : 'GolapProgressDialog',
	#superclass : 'SpProgressDialog',
	#category : 'Golap-UI-Spec',
	#package : 'Golap-UI',
	#tag : 'Spec'
}

{ #category : 'initialization' }
GolapProgressDialog >> initialize [

	super initialize.
	title := ''
]

{ #category : 'initialization' }
GolapProgressDialog >> initializeDialogWindow: aDialogWindowPresenter [

	super initializeDialogWindow: aDialogWindowPresenter.
	aDialogWindowPresenter
		initialExtent: aDialogWindowPresenter initialExtent x @ 50;
		title: self title
]

{ #category : 'accessing - deprecated' }
GolapProgressDialog >> title [

	^ title
]

{ #category : 'accessing - deprecated' }
GolapProgressDialog >> title: aString [

	title := aString
]
