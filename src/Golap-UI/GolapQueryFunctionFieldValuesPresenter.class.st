Class {
	#name : #GolapQueryFunctionFieldValuesPresenter,
	#superclass : #GolapQueryFunctionValuesPresenter,
	#instVars : [
		'fieldDropList',
		'serverConfigFieldsKey'
	],
	#category : #'Golap-UI-StructuredEditor'
}

{ #category : #specs }
GolapQueryFunctionFieldValuesPresenter class >> defaultSpec [
	<spec>
	^ SpBoxLayout newVertical
		add: #fieldDropList height: self inputTextHeight;
		add: super defaultSpec;
		yourself
]

{ #category : #accessing }
GolapQueryFunctionFieldValuesPresenter >> beItemQuery [
	serverConfigFieldsKey := 'itemAttFile'
]

{ #category : #accessing }
GolapQueryFunctionFieldValuesPresenter >> beTransactionQuery [
	serverConfigFieldsKey := 'traAttFile'
]

{ #category : #accessing }
GolapQueryFunctionFieldValuesPresenter >> field [
	^ fieldDropList selectedItem
]

{ #category : #initialization }
GolapQueryFunctionFieldValuesPresenter >> initialize [
	super initialize.
	serverConfigFieldsKey := 'itemAttFile'
]

{ #category : #initialization }
GolapQueryFunctionFieldValuesPresenter >> initializePresenters [
	super initializePresenters.
	fieldDropList := self newDropList
		whenSelectedItemChangedDo: [ self resetValuesList ]
]

{ #category : #accessing }
GolapQueryFunctionFieldValuesPresenter >> networkClient: aGolapNetworkClientPresenter [
	super networkClient: aGolapNetworkClientPresenter.
	self updateFieldDropList
]

{ #category : #updating }
GolapQueryFunctionFieldValuesPresenter >> updateFieldDropList [
	networkClient
		ifNotNil: [ fieldDropList
				items:
					(networkClient serverConfig
						ifNotNil: [ :config | 
							(((config at: serverConfigFieldsKey ifAbsentPut: [ Dictionary new ])
								at: 'strFields'
								ifAbsent: [ String new ]) substrings: ',')
								,
									(((config at: serverConfigFieldsKey ifAbsentPut: [ Dictionary new ])
										at: 'numFields'
										ifAbsent: [ String new ]) substrings: ',') ]
						ifNil: [ Array new ]) ]
]
