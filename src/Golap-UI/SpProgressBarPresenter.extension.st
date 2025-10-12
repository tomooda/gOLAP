Extension { #name : 'SpProgressBarPresenter' }

{ #category : '*Golap-UI' }
SpProgressBarPresenter >> value: aNumber message: aString [

	self state:
		(GolapManualProgressBarState value: aNumber message: aString)
]
