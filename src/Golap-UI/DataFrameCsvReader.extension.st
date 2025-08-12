Extension { #name : 'DataFrameCsvReader' }

{ #category : '*Golap-UI' }
DataFrameCsvReader >> readFrom: aFileReference interim: aBlock frequency: anInteger [
	"Read data frame from a CSV file"

	| df |
	df := self
		      readFromInternal: aFileReference
		      interim: aBlock
		      frequency: anInteger.
	shouldInferTypes ifTrue: [
			DataFrameTypeDetector new
				columnTypes: columnTypes;
				detectTypesAndConvert: df ].
	^ df
]

{ #category : '*Golap-UI' }
DataFrameCsvReader >> readFromInternal: aFileReference interim: aBlock frequency: anInteger [
	"Read data frame from a CSV file"

	| stream reader df scale last |
	stream := aFileReference readStream.
	reader := NeoCSVReader on: stream.
	reader separator: self separator.
	scale := anInteger asFloat / stream size asFloat.
	last := 0.
	self readColumnNamesWith: reader.
	self readRowsWith: reader interim: [
			| value |
			value := (stream position * scale) truncated.
			last < value ifTrue: [
					last := value.
					aBlock value: value asFloat / anInteger asFloat ] ].
	reader close.
	df := self createDataFrame.
	^ df
]

{ #category : '*Golap-UI' }
DataFrameCsvReader >> readOnlyRowsWith: aReader interim: aBlock [

	rows := OrderedCollection new.

	[ aReader atEnd ] whileFalse: [
			rows add: aReader next.
			aBlock value ]
]

{ #category : '*Golap-UI' }
DataFrameCsvReader >> readRowsAndRowNamesWith: aReader interim: aBlock [
	| line |
	rowNames := OrderedCollection new.
	rows := OrderedCollection new.

	[ aReader atEnd ] whileFalse: [
		line := aReader next.
		rowNames add: line first.
		rows add: line copyWithoutFirst.
		aBlock value ]
]

{ #category : '*Golap-UI' }
DataFrameCsvReader >> readRowsWith: aReader interim: aBlock [

	^ self includeRowNames
		  ifTrue: [ self readRowsAndRowNamesWith: aReader interim: aBlock ]
		  ifFalse: [ self readOnlyRowsWith: aReader interim: aBlock ]
]
