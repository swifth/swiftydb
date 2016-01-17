//
//  Table.swift
//  SQLiteGenerator
//
//  Created by Øyvind Grimnes on 26/12/15.
//

import Foundation

internal enum SQLiteConflictResolution: String {
    case Rollback = "ROLLBACK"
    case Abort =    "ABORT"
    case Fail =     "FAIL"
    case Ignore =   "IGNORE"
    case Replace =  "REPLACE"
}

internal enum TableType: String {
    case Normal = ""
    case Temporary = "TEMPORARY"
}

internal class Table {
    
    internal var name: String
    internal var tableAlias: String?
    internal var relationships: [Relationship] = []
    internal var columns: [String: Column] = [:]
    internal var conflictResolution: SQLiteConflictResolution = .Abort
    internal var type: TableType = .Normal
    internal var shouldSelectAll = false
    
    internal init(_ name: String, alias: String? = nil) {
        self.name = name
        self.tableAlias = alias
    }
    
    internal func addRelationship(relationship: ColumnRelationship, betweenColumn column: Column, andColumn otherColumn: Column) {
        addRelationship(relationship, betweenColumn: column, andValue: otherColumn.identifier)
    }
    
    internal func addRelationship(relationship: ColumnRelationship, betweenColumn column: Column, andValue value: Any?) {
        relationships.append(Relationship(column: column, relationship: relationship, value: value))
    }

    internal func column(name: String) -> Column {
        let column = Column(name: name, table: self)
        
        if let existingColumn = columns[column.identifier]{
            return existingColumn
        }
        
        columns[column.identifier] = column
        
        return column
    }
}

// MARK: - Identifiers
extension Table {
    
    /** The keypath for the column: 'table'.'name' */
    internal var fullName: String {
        return "\(name)"
    }
    
    /** Alias if possible, else the full name */
    internal var identifier: String {
        return tableAlias ?? fullName
    }
    
    /** Defining alias as: 'fullName' AS 'alias' */
    internal var aliasDefinition: String? {
        return tableAlias != nil ? "\(fullName) AS \(tableAlias!)" : nil
    }
    
    /** Returns alias definition if alias is defined, else full name */
    internal var definition: String {
        return aliasDefinition ?? fullName
    }
}

//MARK: SELECT
extension Table {
    internal func selectAll() -> Table {
        shouldSelectAll = true
        return self
    }
    
    internal func alias(alias: String) -> Table {
        tableAlias = alias
        return self
    }
}

// MARK: CREATE
extension Table {
    internal func temporary() -> Table {
        type = .Temporary
        return self
    }
    
    internal func onConflict(resolution: SQLiteConflictResolution) -> Table {
        conflictResolution = resolution
        return self
    }
}