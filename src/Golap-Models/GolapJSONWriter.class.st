Class {
	#name : 'GolapJSONWriter',
	#superclass : 'STONWriter',
	#category : 'Golap-Models-JSON',
	#package : 'Golap-Models',
	#tag : 'JSON'
}

{ #category : 'initialization' }
GolapJSONWriter >> initialize [

	super initialize.
	jsonMode := true
]

{ #category : 'writing' }
GolapJSONWriter >> writeFloat: float [

	float isFinite
		ifTrue: [ writeStream print: float ]
		ifFalse: [
				| argument |
				argument := float isNaN
					            ifTrue: [ writeStream nextPutAll: 'NaN' ]
					            ifFalse: [
							            float negative
								            ifTrue: [ writeStream nextPutAll: '-Infinity' ]
								            ifFalse: [ 'Infinity' ] ] ]
]
