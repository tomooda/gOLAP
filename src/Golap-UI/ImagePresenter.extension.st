Extension { #name : #ImagePresenter }

{ #category : #'*Golap-UI' }
ImagePresenter >> autoScale [
	"<api: #inspect>"

	^ autoScaleHolder value
]

{ #category : #'*Golap-UI' }
ImagePresenter >> autoScale: aBoolean [
	"<api: #inspect>"

	autoScaleHolder value: aBoolean = true
]
