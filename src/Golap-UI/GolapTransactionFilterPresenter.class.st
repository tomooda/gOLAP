Class {
	#name : #GolapTransactionFilterPresenter,
	#superclass : #GolapFilterPresenter,
	#instVars : [
		'subqueryDropList'
	],
	#category : #'Golap-UI-Query'
}

{ #category : #layout }
GolapTransactionFilterPresenter class >> defaultLayout [

	<script: 'GolapTransactionFilterPresenter forCurrent openWithSpec'>
	<spec>
	^ SpBoxLayout newHorizontal
		  add: (SpBoxLayout newVertical
				   add: '変数' expand: false;
				   add: #clauseList expand: true);
		  add: (SpBoxLayout newVertical
				   add: (SpBoxLayout newHorizontal
						    add: 'フィルタ' expand: false;
						    add: #subqueryDropList expand: true)
				   expand: false;
				   add: #predicateList expand: true;
				   add: #predicateField expand: false;
				   add: (SpBoxLayout newHorizontal
						    add: #guardFieldDropList expand: false;
						    add: #guardPredicatesField expand: true)
				   expand: false);
		  add: (SpBoxLayout newVertical
				   add: 'プレビュー' expand: false;
				   add: #previewList;
				   add: #previewFilterField expand: false)
]

{ #category : #operations }
GolapTransactionFilterPresenter >> clauseListSelectionChanged [
	self updateSubqueryDropList.
	super clauseListSelectionChanged
]

{ #category : #accessing }
GolapTransactionFilterPresenter >> filterSpec [
	^ self query transactionFilterSpec
]

{ #category : #initialization }
GolapTransactionFilterPresenter >> initializePresenters [
	super initializePresenters.
	subqueryDropList := self newDropList
		items: {nil . false . true};
		display: [ :item | 
			item
				ifNil: [ '' ]
				ifNotNil: [ item
						ifTrue: [ '全アイテム関連' ]
						ifFalse: [ '含アイテム関連' ] ] ];
		whenSelectedItemChangedDo: [ self subqueryDropListChanged ];
		yourself
]

{ #category : #testing }
GolapTransactionFilterPresenter >> isPredicateMode [
	^ subqueryDropList selectedItem isNil
]

{ #category : #testing }
GolapTransactionFilterPresenter >> isSubqueryMode [
	^ subqueryDropList selectedItem notNil
]

{ #category : #operations }
GolapTransactionFilterPresenter >> predicateFieldAccepted [
	self isPredicateMode
		ifTrue: [ ^ super predicateFieldAccepted ].
	predicateList selection selectedItem
		ifNotNil: [ :clause | 
			clause
				predicates:
					((predicateField text asString substrings: ',')
						collect: [ :predicateText | 
							GolapQueryPredicateSpec
								fromString: predicateText trim
								ifError: [ nil ] ]
						thenSelect: #notNil) asOrderedCollection.
			self updateClauseList ]
]

{ #category : #operations }
GolapTransactionFilterPresenter >> predicateFieldDropped: anArrayOfString [
	| patterns newPatterns |
	(self isPredicateMode
		or: [ predicateField text asString trim isEmpty ])
		ifTrue: [ ^ super predicateFieldDropped: anArrayOfString ].
	patterns := (predicateField text asString substrings: ',')
		collect: [ :string | 
			(((#('\' '.' '[' ']' '(' ')' '!' '+' '|')
				inject: string
				into: [ :p :special | p copyReplaceAll: special with: '\' , special ])
				copyReplaceAll: '*'
				with: '.*') copyReplaceAll: '?' with: '[ -~]+') asRegex ].
	newPatterns := anArrayOfString
		reject: [ :string | patterns anySatisfy: [ :p | p matches: string ] ].
	newPatterns
		ifNotEmpty: [ predicateField
				accept: predicateField text asString trim , ',' , (',' join: newPatterns) ]
]

{ #category : #operations }
GolapTransactionFilterPresenter >> removePredicate [
	self isPredicateMode
		ifTrue: [ ^ super removePredicate ].
	predicateList selectedItem
		ifNotNil: [ :clause | 
			clause removeAllPredicates.
			self updateClauseList ]
]

{ #category : #accessing }
GolapTransactionFilterPresenter >> subqueryDropList [
	^ subqueryDropList
]

{ #category : #operations }
GolapTransactionFilterPresenter >> subqueryDropListChanged [
	clauseList selection selectedItem
		ifNotNil: [ :clause | 
			clause isTransactionClause
				ifTrue: [ subqueryDropList selectedItem
						ifNil: [ clause removeItemFilter ]
						ifNotNil: [ :quantifier | 
							predicateList items: #().
							clause removeAllPredicates.
							clause itemFilter
								ifNil: [ clause
										itemFilterFromFields: (query itemFilterSpec clauses collect: #field)
										quantifier: quantifier ]
								ifNotNil: [ clause itemFilterQuantifier: quantifier ] ] ].
			self updateClauseList ]
]

{ #category : #updating }
GolapTransactionFilterPresenter >> updateGuard [
	self isPredicateMode
		ifTrue: [ ^ super updateGuard ].
	guardFieldDropList
		items: #();
		disable.
	guardPredicatesField
		text: '';
		disable
]

{ #category : #updating }
GolapTransactionFilterPresenter >> updatePredicateField [
	self isPredicateMode
		ifTrue: [ ^ super updatePredicateField ].
	predicateList selection selectedItem
		ifNotNil: [ :clause | 
			predicateField
				text: (',' join: (clause predicates collect: #printSpec));
				selectAll ]
		ifNil: [ predicateField text: '' ].
	self updateGuard.
	self updatePreviewList
]

{ #category : #updating }
GolapTransactionFilterPresenter >> updatePredicateList [
	self isPredicateMode
		ifTrue: [ ^ super updatePredicateList ].
	clauseList selection selectedItem
		ifNotNil: [ :clause | 
			| oldSelection |
			oldSelection := predicateList selection selectedItem.
			predicateList items: clause itemFilter clauses.
			(clause itemFilter clauses includes: oldSelection)
				ifTrue: [ predicateList selectItem: oldSelection ]
				ifFalse: [ predicateList unselectAll ] ]
		ifNil: [ predicateList
				items: #();
				resetSelection ].
	self updatePredicateField.
	self updatePreviewList
]

{ #category : #updating }
GolapTransactionFilterPresenter >> updatePreviewList [
	self isPredicateMode
		ifTrue: [ ^ super updatePreviewList ].
	Cursor wait
		showWhile: [ previewList
				items:
					(predicateList selection selectedItem
						ifNotNil:
							[ :clause | previewFilterBlock value: (self availableItemsFor: clause) ]
						ifNil: [ #() ]) ]
]

{ #category : #updating }
GolapTransactionFilterPresenter >> updateSubqueryDropList [
	clauseList selection selectedItem
		ifNil: [ subqueryDropList
				disable;
				resetSelection ]
		ifNotNil: [ :clause | 
			clause isTransactionClause
				ifTrue: [ subqueryDropList
						enable;
						selectItem: clause itemFilterQuantifier ]
				ifFalse: [ subqueryDropList
						disable;
						resetSelection ] ]
]
