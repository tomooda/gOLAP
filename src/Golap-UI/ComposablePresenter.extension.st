Extension { #name : #ComposablePresenter }

{ #category : #'*Golap-UI' }
ComposablePresenter >> whenExtentChangedDo: aBlock [
	extentHolder whenChangedDo: aBlock
]
