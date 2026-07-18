Class {
	#name : 'GolapBaseNode',
	#superclass : 'Object',
	#instVars : [
		'data',
		'name'
	],
	#category : 'Golap-Models-Base-Graph',
	#package : 'Golap-Models',
	#tag : 'Base-Graph'
}

{ #category : 'instance creation' }
GolapBaseNode class >> id: aString name: anotherString data: aDictionary [

	^ self new
		  data:
			  (DataSeries withKeys: aDictionary keys values: aDictionary values);
		  id: aString asString;
		  name: (anotherString ifNil: [ aString ]) asString;
		  yourself
]

{ #category : 'arithmetics' }
GolapBaseNode >> - aGolapBaseNode [

	| diff |
	diff := self copy.
	diff data ifNotNil: [ :diffData |
			aGolapBaseNode data ifNotNil: [ :subtrahendData |
					subtrahendData keysAndValuesDo: [ :key :subtrahend |
							subtrahend isNumber ifTrue: [
								diffData
									at: key
									put: (diffData at: key ifAbsent: [ 0 ]) - subtrahend ] ] ] ].
	^ diff
]

{ #category : 'converting' }
GolapBaseNode >> asGolapNode [

	^ GolapNode on: data copy name: name
]

{ #category : 'accessing' }
GolapBaseNode >> data [

	^ data
]

{ #category : 'accessing' }
GolapBaseNode >> data: aDataSeries [

	data := aDataSeries
]

{ #category : 'accessing' }
GolapBaseNode >> id [

	^ data name
]

{ #category : 'accessing' }
GolapBaseNode >> id: aString [

	data name: aString asString
]

{ #category : 'accessing' }
GolapBaseNode >> name [

	^ name
]

{ #category : 'accessing' }
GolapBaseNode >> name: aString [

	name := aString asString
]

{ #category : 'arithmetics' }
GolapBaseNode >> negated [

	| negative |
	negative := self shallowCopy.
	negative data: (negative data collect: [ :value |
			 value isNumber ifTrue: [ value negated ] ]).
	^ negative
]

{ #category : 'copying' }
GolapBaseNode >> postCopy [

	super postCopy.
	data := data copy
]
