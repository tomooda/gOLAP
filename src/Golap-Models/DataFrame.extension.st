Extension { #name : #DataFrame }

{ #category : #'*Golap-Models' }
DataFrame class >> readFrom: aLocation using: aDataFrameReader forceStringColumns: aCollectionOfString [
	"Read data frame from a given location using a given DataFrameReader. Location can be a file reference, a database connection, or something else (depending on the implementation of the reader)"
	^ aDataFrameReader readFrom: aLocation forceStringColumns: aCollectionOfString
]

{ #category : #'*Golap-Models' }
DataFrame class >> readFromCsv: aFileReference forceStringColumns: aCollectionOfString [
	| reader |
	reader := DataFrameCsvReader new.
	^ self
		readFrom: aFileReference
		using: reader
		forceStringColumns: aCollectionOfString
]

{ #category : #'*Golap-Models' }
DataFrame class >> withRows: anArrayOfArrays columnNames: anArrayOfColumnNames [
	^ anArrayOfArrays
		ifNotEmpty: [ (self withRows: anArrayOfArrays)
				columnNames: anArrayOfColumnNames;
				yourself ]
		ifEmpty: [ self withColumnNames: anArrayOfColumnNames ]
]
