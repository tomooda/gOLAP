Class {
	#name : 'GolapQueryJSONReader',
	#superclass : 'NeoJSONReader',
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'accessing' }
GolapQueryJSONReader >> mapClass [
	"Return the collection type to use for JSON maps"

	^ mapClass ifNil: [ HiDeSyntaxDictionary ]
]
