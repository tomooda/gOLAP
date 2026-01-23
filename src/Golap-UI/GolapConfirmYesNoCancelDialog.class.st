Class {
	#name : 'GolapConfirmYesNoCancelDialog',
	#superclass : 'SpAbstractCancelableMessageDialog',
	#instVars : [
		'answer'
	],
	#category : 'Golap-UI-Spec',
	#package : 'Golap-UI',
	#tag : 'Spec'
}

{ #category : 'accessing' }
GolapConfirmYesNoCancelDialog class >> defaultAcceptLabel [

	^ 'Yes'
]

{ #category : 'accessing' }
GolapConfirmYesNoCancelDialog class >> defaultCancelLabel [

	^ 'Cancel'
]

{ #category : 'accessing' }
GolapConfirmYesNoCancelDialog class >> defaultExtent [

	^ 450@120
]

{ #category : 'accessing' }
GolapConfirmYesNoCancelDialog class >> defaultPreferredExtent [

	^ 450@120
]

{ #category : 'accessing' }
GolapConfirmYesNoCancelDialog class >> defaultRejectLabel [

	^ 'No'
]

{ #category : 'private' }
GolapConfirmYesNoCancelDialog >> accept [

	answer := true.
	super accept
]

{ #category : 'initialization' }
GolapConfirmYesNoCancelDialog >> addButtonsTo: aDialogWindowPresenter [

	aDialogWindowPresenter
		addButton: self cancelLabel
		do: [ :presenter | self cancel ].
	aDialogWindowPresenter
		addButton: self rejectLabel
		do: [ :presenter | self reject ].
	aDialogWindowPresenter
		addDefaultButton: self acceptLabel
		do: [ :presenter | self accept ]
]

{ #category : 'private' }
GolapConfirmYesNoCancelDialog >> cancel [

	answer := nil.
	super cancel
]

{ #category : 'accessing' }
GolapConfirmYesNoCancelDialog >> defaultTitle [
	"This is the title of the dialog not the window"
	
	'gOLAP'
]

{ #category : 'showing' }
GolapConfirmYesNoCancelDialog >> openModal [

	| dialog |
	dialog := super openModal.
	^ answer
]

{ #category : 'private' }
GolapConfirmYesNoCancelDialog >> reject [

	answer := false.
	self window close
]

{ #category : 'accessing' }
GolapConfirmYesNoCancelDialog >> rejectLabel [

	^ self class defaultRejectLabel
]
