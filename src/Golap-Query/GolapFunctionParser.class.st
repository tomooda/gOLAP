Class {
	#name : #GolapFunctionParser,
	#superclass : #PP2CompositeNode,
	#category : #'Golap-Query'
}

{ #category : #accessing }
GolapFunctionParser >> start [
	"Answer the production to start this parser with."

	^ self string
]

{ #category : #accessing }
GolapFunctionParser >> string [
	^ ($" asPParser
		,
			(('\"' asPParser ==> [ :s | $" ])
				/ (($" asPParser not , #any asPParser) ==> #second)) star
		, $" asPParser) ==> [ :triple | String withAll: triple second ]
]
