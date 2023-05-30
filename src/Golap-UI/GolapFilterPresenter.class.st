Class {
	#name : #GolapFilterPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'query',
		'clauseList',
		'guardFieldDropList',
		'guardPredicatesField',
		'predicateField',
		'predicateList',
		'previewList',
		'previewFilterField',
		'previewFilterBlock'
	],
	#category : #'Golap-UI-Query'
}

{ #category : #layout }
GolapFilterPresenter class >> defaultLayout [

	<script: 'GolapItemFilterPresenter forCurrent openWithSpec'>
	<spec>
	^ SpBoxLayout newHorizontal
		  add: (SpBoxLayout newVertical
				   add: '変数' expand: false;
				   add: #clauseList expand: true);
		  add: (SpBoxLayout newVertical
				   add: 'フィルタ' expand: false;
				   add: #predicateList expand: true;
				   add: #predicateField expand: false;
				   add: (SpBoxLayout newHorizontal
						    add: #guardFieldDropList expand: false;
						    add: #guardPredicatesField expand: true)
				   expand: false);
		  add: (SpBoxLayout newVertical
				   add: 'プレビュー' expand: false;
				   add: #previewList expand: true;
				   add: #previewFilterField expand: false)
]

{ #category : #'instance creation' }
GolapFilterPresenter class >> for: aGolapQueryPresenter [
	^ self new
		query: aGolapQueryPresenter;
		yourself
]

{ #category : #'instance creation' }
GolapFilterPresenter class >> forCurrent [
	<script: 'GolapItemFilterPresenter forCurrent inspect'>
	^ self for: GolapNetworkClientPresenter current
]

{ #category : #operations }
GolapFilterPresenter >> addGuard [
	predicateList selection selectedItem
		ifNotNil: [ :predicate | 
			guardFieldDropList selectedItem
				ifNotNil: [ :guardField | 
					((guardPredicatesField text asString substrings: ',')
						collect:
							[ :predicateString | GolapQueryPredicateSpec fromString: predicateString ifError: [ nil ] ]
						thenSelect: #notNil)
						ifNotEmpty: [ :guardPredicates | 
							predicate
								guard: (GolapQueryItemClauseSpec on: guardField withAll: guardPredicates) ]
						ifEmpty: [ predicate guard: nil ].
					self updatePredicateList ]
				ifNil: [ guardPredicatesField text: '' ] ]
]

{ #category : #operations }
GolapFilterPresenter >> addPredicate [
	self addPredicate: predicateField text asString
]

{ #category : #operations }
GolapFilterPresenter >> addPredicate: aString [
	| clause predicates oldPredicate newPredicate |
	clause := clauseList selection selectedItem.
	clause ifNil: [ ^ nil ].
	predicates := clause predicates asSet.
	oldPredicate := predicateList selection selectedItem.
	newPredicate := nil.
	(aString substrings: ',')
		do: [ :rawString | 
			rawString
				ifEmpty: [ nil ]
				ifNotEmpty: [ :string | 
					(GolapQueryPredicateSpec fromString: string ifError: [ nil ])
						ifNotNil: [ :predicate | 
							newPredicate := predicate.
							(predicates includes: predicate)
								ifFalse: [ clause addPredicate: predicate.
									predicates add: predicate.
									oldPredicate
										ifNotNil: [ clause removePredicate: oldPredicate ifAbsent: [  ] ] ] ] ] ].
	self updateClauseList.
	clauseList selectItem: clause.
	predicateList selectItem: newPredicate
]

{ #category : #operations }
GolapFilterPresenter >> addPredicateSilent: aString [
	| clause predicates oldPredicate |
	clause := clauseList selection selectedItem.
	clause ifNil: [ ^ nil ].
	predicates := clause predicates asSet.
	oldPredicate := predicateList selection selectedItem.
	(aString substrings: ',')
		do: [ :rawString | 
			rawString
				ifEmpty: [ nil ]
				ifNotEmpty: [ :string | 
					(GolapQueryPredicateSpec fromString: string ifError: [ nil ])
						ifNotNil: [ :predicate | 
							(predicates includes: predicate)
								ifFalse: [ clause addPredicate: predicate.
									predicates add: predicate ] ] ] ].
	predicateList selectItem: oldPredicate.
	self updateClauseList.
	clauseList selectItem: clause
]

{ #category : #accessing }
GolapFilterPresenter >> authenticateBlock [
	^ query ifNotNil: #authenticateBlock
]

{ #category : #accessing }
GolapFilterPresenter >> availableItemsFor: aGolapQueryClauseSpec [
	^ self networkClient
		ifNotNil: [ :client | client valuesAtField: aGolapQueryClauseSpec field ]
		ifNil: [ Array new ]
]

{ #category : #menus }
GolapFilterPresenter >> clauseHasPredicates [
	^ clauseList selection selectedItem
		ifNotNil: [ :clause | clause hasPredicates ]
		ifNil: [ false ]
]

{ #category : #'accessing-widgets' }
GolapFilterPresenter >> clauseList [
	^ clauseList
]

{ #category : #menus }
GolapFilterPresenter >> clauseListMenu [
	| menu |
	menu := self newMenu.
	clauseList selection selectedItem
		ifNotNil: [ :clause | 
			menu
				addGroup: [ :menuGroup | 
					menuGroup
						addItem: [ :menuItem | 
							menuItem
								name:
									(clause isNegative
										ifTrue: [ 'make positive' ]
										ifFalse: [ 'make negative' ]);
								action: [ self toggleNegative ] ] ];
				addGroup: [ :menuGroup | 
					menuGroup
						addItem: [ :menuItem | 
							menuItem
								name: 'clear filters';
								action: [ self clearClause ];
								enabled: self clauseHasPredicates ] ] ].
	^ menu
]

{ #category : #operations }
GolapFilterPresenter >> clauseListSelectionChanged [
	previewFilterField text: ''.
	previewFilterBlock := [ :items | items ].
	self updatePredicateList
]

{ #category : #operations }
GolapFilterPresenter >> clearClause [
	| clause |
	clause := clauseList selection selectedItem ifNil: [ ^ nil ].
	clause removeAllPredicates.
	self updateClauseList.
	predicateList unselectAll
]

{ #category : #operations }
GolapFilterPresenter >> copyPreviewListSelection [
	Clipboard clipboardText: (',' join: previewList selectedItems)
]

{ #category : #accessing }
GolapFilterPresenter >> filterSpec [
	^ self subclassResponsibility
]

{ #category : #'accessing-widgets' }
GolapFilterPresenter >> guardFieldDropList [
	^ guardFieldDropList
]

{ #category : #'accessing-widgets' }
GolapFilterPresenter >> guardPredicatesField [
	^ guardPredicatesField
]

{ #category : #operations }
GolapFilterPresenter >> guardPredicatesFieldAccepted [
	self addGuard
]

{ #category : #initialization }
GolapFilterPresenter >> initializePresenters [

	clauseList := self newTable
		              disableSearch;
		              beSingleSelection;
		              addColumn: (SpStringTableColumn new
				               width: 20;
				               evaluated: [ :clauseSpec | 
					               (clauseSpec hasPredicates or: [ 
							                clauseSpec hasItemFilter ])
						               ifTrue: [ 
							               clauseSpec isNegative
								               ifTrue: [ '-' ]
								               ifFalse: [ '+' ] ]
						               ifFalse: [ ' ' ] ]);
		              addColumn:
		              (SpStringTableColumn evaluated: [ :clauseSpec | 
			               clauseSpec field ]);
		              itemFilter: [ :clauses | clauses ];
		              whenSelectionChangedDo: [ 
		              self clauseListSelectionChanged ];
		              contextMenu: [ self clauseListMenu ];
		              contextKeyBindings: (CmCommandGroup forSpec
				               beDisplayedAsGroup;
				               register: (CmBlockCommand new
						                name: 'toggle';
						                block: [ self toggleNegative ];
						                asSpecCommandWithShortcutKey:
							                ($- command | $- control) asShortcut);
				               register: (CmBlockCommand new
						                name: 'remove';
						                block: [ self clearClause ];
						                asSpecCommandWithShortcutKey:
							                ($x command | $x control) asShortcut);
				               yourself) asKMCategory;
		              whenBuiltDo: [ :w | w widget disableFunction ];
		              borderColor: (Color gray: 0.9);
		              borderWidth: 1;
		              yourself.
	predicateList := self newList
		                 display: [ :spec | 
			                 spec isPredicateSpec
				                 ifTrue: [ spec printSpec ]
				                 ifFalse: [ 
					                 (spec hasPredicates
						                  ifTrue: [ 
							                  spec isNegative
								                  ifTrue: [ '-' ]
								                  ifFalse: [ '+' ] ]
						                  ifFalse: [ ' ' ]) , spec field ] ];
		                 dropEnabled: true;
		                 acceptDrop: [ :transfer | 
			                 self addPredicateSilent:
					                 (',' join: transfer passenger) ];
		                 whenSelectionChangedDo: [ 
			                 self predicateListSelectionChanged ];
		                 contextMenu: [ self predicateListMenu ];
		                 contextKeyBindings: (CmCommandGroup forSpec
				                  beDisplayedAsGroup;
				                  register: (CmBlockCommand new
						                   name: 'remove';
						                   block: [ self removePredicate ];
						                   asSpecCommandWithShortcutKey:
							                   ($x command | $x control) asShortcut);
				                  yourself) asKMCategory;
		                 whenBuiltDo: [ predicateList dropEnabled: true ];
		                 borderColor: (Color gray: 0.9);
		                 borderWidth: 1;
		                 yourself.
	predicateField := self newTextInput
		                  dropEnabled: true;
		                  acceptDrop: [ :transfer | 
			                  self predicateFieldDropped: transfer passenger ];
		                  whenSubmitDo: [ :txt | 
			                  self predicateFieldAccepted ];
		                  borderColor: (Color gray: 0.9);
		                  borderWidth: 1;
		                  yourself.
	guardFieldDropList := self newDropList
		                      display: [ :clauseSpec | 
			                      clauseSpec ifNil: [ '-' ] ];
		                      yourself.
	guardPredicatesField := self newTextInput
		                        dropEnabled: true;
		                        acceptDrop: [ :transfer | 
			                        guardPredicatesField text:
					                        (',' join: transfer passenger) ];
		                        whenSubmitDo: [ :txt | 
			                        self guardPredicatesFieldAccepted ];
		                        borderColor: (Color gray: 0.9);
		                        borderWidth: 1;
		                        yourself.
	previewList := self newList
		               beMultipleSelection;
		               display: [ :item | item ];
		               dragEnabled: true;
		               contextMenu: [ self previewListMenu ];
		               contextKeyBindings: (CmCommandGroup forSpec
				                beDisplayedAsGroup;
				                register: (CmBlockCommand new
						                 name: 'copy';
						                 block: [ self copyPreviewListSelection ];
						                 asSpecCommandWithShortcutKey:
							                 ($c command | $c control) asShortcut);
				                yourself) asKMCategory;
		               borderColor: (Color gray: 0.9);
		               borderWidth: 1;
		               yourself.
	previewFilterBlock := [ :items | items ].
	previewFilterField := self newTextInput
		                      whenSubmitDo: [ :txt | 
			                      ((previewFilterField text asString trim 
				                        substrings: ',') collect: [ :string | 
					                       (((#( '\' '.' '[' ']' '(' ')' '!' '+' '|' )
						                          inject: string
						                          into: [ :p :special | 
							                          p
								                          copyReplaceAll: special
								                          with: '\' , special ])
						                         copyReplaceAll: '*'
						                         with: '.*')
						                        copyReplaceAll: '?'
						                        with: '[ -~]+') asRegex ])
				                      ifEmpty: [ 
					                      previewFilterBlock := [ :items | items ] ]
				                      ifNotEmpty: [ :regexs | 
					                      previewFilterBlock := [ :items | 
					                                            items select: [ :item | 
							                                            regexs anySatisfy: [ 
									                                            :regex | 
									                                            regex matches:
											                                            item ] ] ] ].
			                      self updatePreviewList ];
		                      borderColor: (Color gray: 0.9);
		                      borderWidth: 1;
		                      yourself.
	self focusOrder
		add: clauseList;
		add: predicateList;
		add: predicateField;
		add: previewList;
		add: previewFilterField;
		add: guardFieldDropList;
		add: guardPredicatesField.
	self whenBuiltDo: [ :w | 
		| font |
		font := TextStyle defaultFont.
		w widget allMorphsDo: [ :m | 
			(m respondsTo: #font:) ifTrue: [ m font: font ] ] ]
]

{ #category : #accessing }
GolapFilterPresenter >> networkClient [
	^ query ifNotNil: #networkClient
]

{ #category : #'accessing-widgets' }
GolapFilterPresenter >> predicateField [
	^ predicateField
]

{ #category : #operations }
GolapFilterPresenter >> predicateFieldAccepted [
	self addPredicate
]

{ #category : #operations }
GolapFilterPresenter >> predicateFieldDropped: anArrayOfString [
	predicateField text: (',' join: anArrayOfString)
]

{ #category : #'accessing-widgets' }
GolapFilterPresenter >> predicateList [
	^ predicateList
]

{ #category : #menus }
GolapFilterPresenter >> predicateListMenu [
	^ self newMenu
		addGroup: [ :menuGroup | 
			menuGroup
				addItem: [ :menuItem | 
					menuItem
						name: 'remove';
						action: [ self removePredicate ] ];
				addItem: [ :menuItem | 
					menuItem
						name: 'remove all';
						action: [ self removeAllPredicates ] ] ]
]

{ #category : #operations }
GolapFilterPresenter >> predicateListSelectionChanged [
	self updatePredicateField
]

{ #category : #'accessing-widgets' }
GolapFilterPresenter >> previewFilterField [
	^ previewFilterField
]

{ #category : #'accessing-widgets' }
GolapFilterPresenter >> previewList [ 
	^ previewList
]

{ #category : #menus }
GolapFilterPresenter >> previewListMenu [
	^ self newMenu
		addItem: [ :menuItem | 
			menuItem
				name: 'copy';
				action: [ self copyPreviewListSelection ] ]
]

{ #category : #menus }
GolapFilterPresenter >> previewListMenu: aMenu shifted: shifted [ 
	^ aMenu
		add: 'copy' target: self selector: #copyPreviewListSelection;
		yourself
]

{ #category : #accessing }
GolapFilterPresenter >> query [
	^ query
]

{ #category : #accessing }
GolapFilterPresenter >> query: aGolapQueryPresenter [
	query := aGolapQueryPresenter.
	self updateClauseList
]

{ #category : #operations }
GolapFilterPresenter >> removeAllPredicates [
	| clause |
	clause := clauseList selection selectedItem ifNil: [ ^ nil ].
	clause removeAllPredicates.
	self updateClauseList.
	clauseList selectItem: clause.
	self updatePredicateList.
	predicateList unselectAll
]

{ #category : #operations }
GolapFilterPresenter >> removePredicate [
	| clause predicate |
	clause := clauseList selection selectedItem ifNil: [ ^ nil ].
	predicate := predicateList selection selectedItem ifNil: [ ^ nil ].
	clause removePredicate: predicate ifAbsent: [ ^ nil ].
	self updateClauseList.
	clauseList selectItem: clause.
	self updatePredicateList.
	predicateList unselectAll.
	^ predicate
]

{ #category : #accessing }
GolapFilterPresenter >> timeout [
	^ query timeout
]

{ #category : #operations }
GolapFilterPresenter >> toggleNegative [
	clauseList selection selectedItem
		ifNotNil: [ :clause | 
			clause toggleNegative.
			self updateClauseList.
			clauseList selectItem: clause ]
]

{ #category : #updating }
GolapFilterPresenter >> updateClauseList [
	| oldSelection items |
	oldSelection := clauseList selection selectedItem.
	clauseList items: (items := self filterSpec clauses).
	(items includes: oldSelection)
		ifFalse: [ clauseList unselectAll ].
	self updatePredicateList
]

{ #category : #updating }
GolapFilterPresenter >> updateGuard [
	predicateList selection selectedItem
		ifNotNil: [ :predicate | 
			guardFieldDropList
				items:
					(((self filterSpec clauses
						copyWithout: clauseList selection selectedItem) collect: #field)
						copyWithFirst: nil);
				selectItem: (predicate guard ifNotNil: #field);
				enable.
			guardPredicatesField
				text:
					(','
						join:
							(predicate guard
								ifNotNil: [ :guard | guard predicates collect: #printSpec ]
								ifNil: [ #() ]));
				selectAll;
				enable ]
		ifNil: [ guardFieldDropList
				resetSelection;
				items: #();
				disable.
			guardPredicatesField
				text: '';
				disable ]
]

{ #category : #updating }
GolapFilterPresenter >> updatePredicateField [
	predicateList selection selectedItem
		ifNotNil: [ :predicate | 
			predicateField
				text: predicate printSpec;
				selectAll ]
		ifNil: [ predicateField text: '' ].
	self updateGuard.
	self updatePreviewList
]

{ #category : #updating }
GolapFilterPresenter >> updatePredicateList [
	clauseList selection selectedItem
		ifNotNil: [ :clause | 
			predicateList
				items: clause predicates;
				unselectAll ]
		ifNil: [ predicateList
				items: #();
				unselectAll ].
	self updatePredicateField.
	self updatePreviewList
]

{ #category : #updating }
GolapFilterPresenter >> updatePreviewList [

	Cursor wait showWhile: [ 
		previewList items: (clauseList selection selectedItem
				 ifNotNil: [ :clause | 
					 previewFilterBlock value: (self availableItemsFor: clause) ]
				 ifNil: [ #(  ) ]) ]
]

{ #category : #accessing }
GolapFilterPresenter >> url [
	^ self query url
]
