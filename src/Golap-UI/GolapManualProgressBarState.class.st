Class {
	#name : 'GolapManualProgressBarState',
	#superclass : 'SpProgressBarState',
	#instVars : [
		'value',
		'message'
	],
	#classVars : [
		'NameEndOfLineDelimiter'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
GolapManualProgressBarState class >> value: aNumber [

	^ self value: aNumber message: ''
]

{ #category : 'instance creation' }
GolapManualProgressBarState class >> value: aNumber message: aString [

	^ self new
		  message: aString;
		  value: aNumber;
		  yourself
]

{ #category : 'private' }
GolapManualProgressBarState >> customizeMorphicBar: aProgressBarMorph [

	aProgressBarMorph value: value
]

{ #category : 'private' }
GolapManualProgressBarState >> customizeMorphicLabel: aLabelMorph [

	aLabelMorph contents: message
]

{ #category : 'initialization' }
GolapManualProgressBarState >> initialize [

	super initialize.
	value := 0.0.
	message := ''
]

{ #category : 'accessing' }
GolapManualProgressBarState >> message [

	^ message
]

{ #category : 'accessing' }
GolapManualProgressBarState >> message: aString [

	message := aString asString
]

{ #category : 'accessing' }
GolapManualProgressBarState >> value [

	^ value
]

{ #category : 'accessing' }
GolapManualProgressBarState >> value: aNumber [

	value := aNumber asNumber min: 1.0 max: 0.0
]

{ #category : 'api - events' }
GolapManualProgressBarState >> whenValueChangedDo: aBlock [

	
]
