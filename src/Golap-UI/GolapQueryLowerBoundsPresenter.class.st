Class {
	#name : #GolapQueryLowerBoundsPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'minSupport',
		'minConfidence',
		'minLift',
		'minJaccard',
		'minPMI'
	],
	#category : #'Golap-UI-Query'
}

{ #category : #layout }
GolapQueryLowerBoundsPresenter class >> defaultLayout [
	<script: 'GolapQueryLowerBoundsPresenter new openWithSpec'>
	<spec>
	^ SpGridLayout new
		beColumnHomogeneous;
		borderWidth: 0;
		column: 1 withConstraints: [ :c | c beNotExpand ];
		column: 1 withConstraints: [ :c | c beExpand ];
		row: 1 withConstraints: [ :c | c beNotExpand ];
		row: 2 withConstraints: [ :c | c beNotExpand ];
		row: 3 withConstraints: [ :c | c beNotExpand ];
		row: 4 withConstraints: [ :c | c beNotExpand ];
		row: 5 withConstraints: [ :c | c beNotExpand ];
		add: '最小Support' at: 1 @ 1;
		add: #minSupport at: 2 @ 1;
		add: '最小Confidence' at: 1 @ 2;
		add: #minConfidence at: 2 @ 2;
		add: '最小Lift' at: 1 @ 3;
		add: #minLift at: 2 @ 3;
		add: '最小Jaccard' at: 1 @ 4;
		add: #minJaccard at: 2 @ 4;
		add: '最小PMI' at: 1 @ 5;
		add: #minPMI at: 2 @ 5;
		yourself
]

{ #category : #'instance creation' }
GolapQueryLowerBoundsPresenter class >> for: aGolapQueryPresenter [
	^ self new
		query: aGolapQueryPresenter;
		yourself
]

{ #category : #initialization }
GolapQueryLowerBoundsPresenter >> initializePresenters [
	super initializePresenters.
	minSupport := self newNumberInput
		beFloat;
		number: 0.0;
		autoAccept: true;
		yourself.
	minConfidence := self newNumberInput
		beFloat;
		number: 0.0;
		autoAccept: true;
		yourself.
	minLift := self newNumberInput
		beFloat;
		number: 0.0;
		autoAccept: true;
		yourself.
	minJaccard := self newNumberInput
		beFloat;
		number: 0.0;
		autoAccept: true;
		yourself.
	minPMI := self newNumberInput
		beFloat;
		number: 0.0;
		autoAccept: true;
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
GolapQueryLowerBoundsPresenter >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'しきい値設定'
]

{ #category : #accessing }
GolapQueryLowerBoundsPresenter >> minConfidence [
	^ minConfidence number
]

{ #category : #accessing }
GolapQueryLowerBoundsPresenter >> minConfidence: aNumber [
	minConfidence number: aNumber
]

{ #category : #accessing }
GolapQueryLowerBoundsPresenter >> minJaccard [
	^ minJaccard number
]

{ #category : #accessing }
GolapQueryLowerBoundsPresenter >> minJaccard: aNumber [
	minJaccard number: aNumber
]

{ #category : #accessing }
GolapQueryLowerBoundsPresenter >> minLift [
	^ minLift number
]

{ #category : #accessing }
GolapQueryLowerBoundsPresenter >> minLift: aNumber [
	minLift number: aNumber
]

{ #category : #accessing }
GolapQueryLowerBoundsPresenter >> minPMI [
	^ minPMI number
]

{ #category : #accessing }
GolapQueryLowerBoundsPresenter >> minPMI: aNumber [
	minPMI number: aNumber
]

{ #category : #accessing }
GolapQueryLowerBoundsPresenter >> minSupport [
	^ minSupport number
]

{ #category : #accessing }
GolapQueryLowerBoundsPresenter >> minSupport: aNumber [
	^ minSupport number: aNumber
]
