Extension { #name : #FTPluggableIconListMorphAdaptorDataSource }

{ #category : #'*Golap-UI' }
FTPluggableIconListMorphAdaptorDataSource >> newDataSourceMatching: aFTFilter [
	| newElements wrappedItem text newDataSource modelCopy |
	UIManager default
		displayProgress: 'filtring...'
		from: 0
		to: self elements size // 100
		during: [ :bar | 
			| v |
			v := 0.
			newElements := self elements
				select: [ :each | 
					(v := v + 1) \\ 100 = 0
						ifTrue: [ bar increment ].
					wrappedItem := self elementWrapped: each.
					table columns
						anySatisfy: [ :column | 
							text := column transform: wrappedItem.
							aFTFilter matches: text ] ].
			newDataSource := self copy.
			modelCopy := self model copy.
			modelCopy prepareForFilteredDataSourceWith: newElements.
			newDataSource model: modelCopy ].
	^ newDataSource
]
