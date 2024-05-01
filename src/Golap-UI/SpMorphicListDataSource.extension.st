Extension { #name : 'SpMorphicListDataSource' }

{ #category : '*Golap-UI' }
SpMorphicListDataSource >> dropElements: aCollection index: rowIndex [
	^ model acceptDropBlock
		cull: (model defaultTransferFor: aCollection from: self)
		cull: nil
		cull: nil
]

{ #category : '*Golap-UI' }
SpMorphicListDataSource >> wantsDropElements: aCollection type: type index: rowIndex [
	^ model wantDropBlock cull: nil cull: nil cull: nil
]
