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
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'accessing' }
GolapFilterParser >> field [

	^ (#letter asPParser , (#letter asPParser / #digit asPParser) plus)
		  flatten trimBlanks
]

{ #category : 'accessing' }
GolapFilterParser >> fieldFilter [

	^ isin / guardedIsin / self multiChoiceFieldFilter
]

{ #category : 'accessing' }
GolapFilterParser >> filter [

	^ #any asPParser
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
	  , field
	  , ($, asPParser , (number / string separatedBy: $, asPParser)
		   , $) asPParser) flatten
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
		  trimBlanks
]

{ #category : 'accessing' }
GolapFilterParser >> start [
	"Answer the production to start this parser with."

	^ field end
]

{ #category : 'accessing' }
GolapFilterParser >> string [

	^ ($' asPParser
	   , ('\''' asPParser / ($' asPParser not , #any asPParser)) star
	   , $' asPParser) flatten trimBlanks
]
