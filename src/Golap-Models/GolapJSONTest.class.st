Class {
	#name : 'GolapJSONTest',
	#superclass : 'TestCase',
	#category : 'Golap-Models-Tests',
	#package : 'Golap-Models',
	#tag : 'Tests'
}

{ #category : 'tests' }
GolapJSONTest >> testFromString [

	| array |
	array := GolapJSON fromString: '[-1,null,NaN,-Infinity,-3.14]'.
	self assert: array first equals: -1.
	self assert: array second isNil.
	self assert: array third isNaN.
	self assert: array fourth equals: Float infinity negated.
	self assert: array fifth equals: -3.14
]

{ #category : 'tests' }
GolapJSONTest >> testToString [

	| array |
	array := GolapJSON fromString: (GolapJSON toString: {
				          -1.
				          nil.
				          Float nan.
				          Float infinity negated.
				          -3.14 }).
	self assert: array first equals: -1.
	self assert: array second isNil.
	self assert: array third isNaN.
	self assert: array fourth equals: Float infinity negated.
	self assert: array fifth equals: -3.14
]

{ #category : 'tests' }
GolapJSONTest >> testToStringPretty [

	| array |
	array := GolapJSON fromString: (GolapJSON toStringPretty: {
				          -1.
				          nil.
				          Float nan.
				          Float infinity negated.
				          -3.14 }).
	self assert: array first equals: -1.
	self assert: array second isNil.
	self assert: array third isNaN.
	self assert: array fourth equals: Float infinity negated.
	self assert: array fifth equals: -3.14
]
