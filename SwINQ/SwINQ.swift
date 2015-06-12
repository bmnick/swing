//
//  SwINQ.swift
//  SwINQ
//
//  Created by bnicholas on 10/27/14.
//  Copyright (c) 2014 Ben Nicholas. All rights reserved.
//

import Foundation
import CoreData

class Query {
    
}

class ContainerQuery<T, C: Query> : Query {
    var contained: C
    var vended: T
    
    init(_ vend: T, _ contain: C) {
        contained = contain
        vended = vend
    }
}

class OrderQuery<T, C:Query> : ContainerQuery<T, C> {

    var order: String
    
    required init(vend: T, contain: C, param: String) {
        order = param
        super.init(vend, contain)
    }
}

class FilterQuery<T, C:Query> : ContainerQuery<T, C> {
    var query: String
    
    required init(vend: T, contain: C, queryString: String) {
        query = queryString
        super.init(vend, contain)
    }
}

class NullQuery : Query {
    
}

infix operator -<>- { associativity right }
func -<>-<T> (left: T, param: String) -> OrderQuery<T, NullQuery> {
    return OrderQuery(vend: left, contain: NullQuery(), param: param)
}

func -<>-<T, Q: Query> (left: T, query: ContainerQuery<String, Q>) -> OrderQuery<T, ContainerQuery<String, Q>> {
    return OrderQuery(vend: left, contain: query, param: query.vended)
}

infix operator <-> { associativity right }
func <-><T> (left: T, query: String) -> FilterQuery<T, NullQuery> {
    return FilterQuery(vend: left, contain: NullQuery(), queryString: query)
}

func <-><T, Q: Query> (left: T, query: ContainerQuery<String, Q>) -> FilterQuery<T, ContainerQuery<String, Q>> {
    return FilterQuery(vend: left, contain: query, queryString: query.vended)
}

// --> Event <-- context <-> "timestamp < now" -<>- "timestamp"
// SELECT Event FROM context WHERE "timestamp < now" ORDERBY "timestamp"
// SELECT <NSManagedObject> FROM <NSManagedObjectContext> WHERE <string> ORDERBY <string>
// (SELECT (<NSManagedObject> FROM (<NSManagedObjectContext> WHERE (<string> ORDERBY <string>))))
// (SELECT (<NSManagedObject> FROM (<NSManagedObjectContext> WHERE OrderQuery<string, NULL>)))
// (SELECT (<NSManagedObject> FROM (FilterQuery<NSManagedObjectContext, OrderQuery<string, null>>)))
// (SELECT Tuple<NSFetchRequest, NSManagedObjectContext>)
// [NSManagedObject]
