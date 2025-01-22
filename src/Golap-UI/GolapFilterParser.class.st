Class {
	#name : 'GolapFilterParser',
	#superclass : 'PP2CompositeNode',
	#instVars : [
		'field',
		'string',
		'number',
		'isin',
		'guardedIsin',
		'fieldFilter',
		'filter'
	],
	#classInstVars : [
		'current'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'accessing' }
GolapFilterParser class >> current [

	^ current ifNil: [ current := self new ]
]

{ #category : 'accessing' }
GolapFilterParser >> conjunctiveFilter [

	^ ('and' asPParser trimBlanks , $( asPParser trimBlanks) flatten
	  ,
		  ((fieldFilter separatedBy: $, asPParser trimBlanks)
			   withoutSeparators ==> [ :assocs |
		   (assocs collect: #key) asSet size = assocs size
			   ifTrue: [ assocs asHiDeSyntaxDictionary ]
			   ifFalse: [ PP2Failure message: 'duplicated field conditions' ] ])
	  , $) asPParser trimBlanks flatten ==> [ :triple | triple second ]
]

{ #category : 'accessing' }
GolapFilterParser >> field [

	^ (#letter asPParser , (#letter asPParser / #digit asPParser) plus)
		  flatten
]

{ #category : 'accessing' }
GolapFilterParser >> fieldFilter [

	^ isin / guardedIsin / self multiChoiceFieldFilter
]

{ #category : 'accessing' }
GolapFilterParser >> filter [

	^ fieldFilter ==> [ :assoc | { assoc } asHiDeSyntaxDictionary ]
	  / self conjunctiveFilter / #any asPParser star flatten
]

{ #category : 'accessing' }
GolapFilterParser >> guardedIsin [

	^ ('and' asPParser trimBlanks , $( asPParser trimBlanks) flatten
	  , isin
	  ,
		  ($, asPParser , 'not' asPParser trimBlanks
		   , $( asPParser trimBlanks , isin , $) asPParser trimBlanks
		   , $) asPParser trimBlanks) flatten ==> [ :triple |
	  triple second key
	  -> (triple first , triple second value , triple third) ]
]

{ #category : 'accessing' }
GolapFilterParser >> isin [

	^ ('isin' asPParser trimBlanks , $( asPParser trimBlanks) flatten
	  , field , ($, asPParser trimBlanks
	   , (number / string separatedBy: $, asPParser trimBlanks)
	   , $) asPParser trimBlanks) flatten
	  ==> [ :triple | triple second -> ('' join: triple) ]
]

{ #category : 'accessing' }
GolapFilterParser >> multiChoiceFieldFilter [

	^ ('or' asPParser trimBlanks , $( asPParser) flatten
	  ,
		  ((isin / guardedIsin separatedBy: $, asPParser trimBlanks flatten)
		   ==> [ :array |
			   | name |
			   name := array first key.
			   ((3 to: array size by: 2) allSatisfy: [ :index |
				    (array at: index) key = name ])
				   ifTrue: [
					   name -> ('' join: ((1 to: array size) collect: [ :index |
							     index even
								     ifTrue: [ array at: index ]
								     ifFalse: [ (array at: index) value ] ])) ]
				   ifFalse: [ PP2Failure message: 'field names disagreement' ] ])
	  , $) asPParser trimBlanks flatten ==> [ :triple |
	  triple second isPetit2Failure
		  ifTrue: [ triple second ]
		  ifFalse: [
			  triple second key
			  -> (triple first , triple second value , triple third) ] ]
]

{ #category : 'accessing' }
GolapFilterParser >> number [

	^ ($- asPParser optional , #digit asPParser plus
	   , ($. asPParser , #digit asPParser plus) optional) flatten
]

{ #category : 'accessing' }
GolapFilterParser >> start [
	"Answer the production to start this parser with."

	^ filter end
]

{ #category : 'accessing' }
GolapFilterParser >> string [

	^ ($' asPParser
	   , ('\''' asPParser / ($' asPParser not , #any asPParser)) star
	   , $' asPParser) flatten
]
