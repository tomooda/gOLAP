Extension { #name : 'DataFrame' }

{ #category : '*Golap-UI' }
DataFrame class >> readFrom: aLocation using: aDataFrameReader interim: aBlock frequency: anInteger [
	"Read data frame from a given location using a given DataFrameReader. Location can be a file reference, a database connection, or something else (depending on the implementation of the reader)"

	| df |
	df := aDataFrameReader
		      readFrom: aLocation
		      interim: aBlock
		      frequency: anInteger.
	df calculateDataTypes.
	^ df
]

{ #category : '*Golap-UI' }
DataFrame class >> readFromCsv: aFileReference interim: aBlock frequency: anInteger [

	| reader |
	reader := DataFrameCsvReader new.
	^ self
		  readFrom: aFileReference
		  using: reader
		  interim: aBlock
		  frequency: anInteger
]
