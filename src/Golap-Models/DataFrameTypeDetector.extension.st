Extension { #name : 'DataFrameTypeDetector' }

{ #category : '*Golap-Models' }
DataFrameTypeDetector >> canAllBeDateAndTime: aDataSeries [
	^ false
]

{ #category : '*Golap-Models' }
DataFrameTypeDetector >> canAllBeNumber: aDataSeries [
	| regex |
	regex := '^nan|-nan|NaN|-NaN|inf|[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$'
		asRegex.
	^ aDataSeries
		detect: [ :each | 
			[ each isNil
				ifTrue: [ false ]
				ifFalse: [ (regex matches: each) not ] ]
				on: Error
				do: [ ^ false ] ]
		ifFound: [ false ]
		ifNone: [ true ]
]

{ #category : '*Golap-Models' }
DataFrameTypeDetector >> canAllBeTime: aDataSeries [
	^ false
]

{ #category : '*Golap-Models' }
DataFrameTypeDetector >> canAnyBeFloat: aDataSeries [
	^ aDataSeries
		anySatisfy: [ :each | 
			each notNil
				and: [ (#('inf' 'nan' 'NaN' '-nan' '-NaN') includes: each)
						or: [ each asNumber isFloat ] ] ]
]

{ #category : '*Golap-Models' }
DataFrameTypeDetector >> convertToFloat: aDataSeries [
	| map |
	map := {('inf' -> Float infinity).
	('-inf' -> Float infinity negated).
	('nan' -> Float nan).
	('NaN' -> Float nan).
	('-nan' -> Float nan negated).
	('-NaN' -> Float nan negated)} asDictionary.
	^ aDataSeries
		collect: [ :each | 
			each
				ifNotNil: [ map at: each ifAbsent: [ each asNumber asFloat ] ]
				ifNil: [ Float nan ] ]
]

{ #category : '*Golap-Models' }
DataFrameTypeDetector >> detectTypesAndConvert: aDataFrame exceptColumns: aCollectionOfString [
	aDataFrame columnNames
		do: [ :columnName | 
			(aCollectionOfString includes: columnName)
				ifFalse: [ aDataFrame
						column: columnName
						put:
							(self detectColumnTypeAndConvert: (aDataFrame column: columnName))
								asArray ] ].
	aDataFrame
		rowNames: (self detectColumnTypeAndConvert: aDataFrame rowNames)
]
