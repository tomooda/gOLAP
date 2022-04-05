Extension { #name : #DataFrameCsvReader }

{ #category : #'*Golap-Models' }
DataFrameCsvReader >> readFrom: aFileReference forceStringColumns: aCollectionOfString [
	"Read data frame from a CSV file"
	| stream reader df |
	stream := aFileReference readStream.
	reader := NeoCSVReader on: stream.
	reader separator: self separator.
	
	self readColumnNamesWith: reader.
	self readRowsWith: reader.
	
	reader close.
	
	df := self createDataFrame.
	DataFrameTypeDetector new detectTypesAndConvert: df exceptColumns: aCollectionOfString.
	^ df
	
]
