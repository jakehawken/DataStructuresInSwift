import Foundation

class Node<T:Comparable & CustomStringConvertible>: Comparable, CustomStringConvertible {
  var value: T
  var next: Node<T>?
  
  init(value:T) {
    self.value = value
  }
  
  init(value:T, next:Node<T>) {
    self.value = value
    self.next = next
  }
  
  func append(node: Node<T>) {
    if next != nil {
      next?.append(node: node)
    }
    else {
      next = node
    }
  }
  
  var description: String {
    return "Node(\(self.value))"
  }
  
  func recursiveDescription(precedingString: inout String) -> String {
    precedingString = precedingString + description
    if let nextNode = next {
      precedingString = precedingString + ", "
      return nextNode.recursiveDescription(precedingString: &precedingString)
    }
    return precedingString + "]"
  }
  
  public static func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.value == rhs.value && lhs.next == rhs.next
  }
  
  public static func <(lhs: Node, rhs: Node) -> Bool {
    return lhs.value < rhs.value
  }
  
  public static func <=(lhs: Node, rhs: Node) -> Bool {
    return lhs.value <= rhs.value
  }
  
  public static func >=(lhs: Node, rhs: Node) -> Bool {
    return lhs.value >= rhs.value
  }
  
  public static func >(lhs: Node, rhs: Node) -> Bool {
    return lhs.value > rhs.value
  }
}

class LinkedListIterator<T:Comparable & CustomStringConvertible>: IteratorProtocol {
  private var currentNode: Node<T>?
  
  init(firstNode: Node<T>?) {
    self.currentNode = firstNode
  }
  
  func next() -> Node<T>? {
    let current = currentNode
    currentNode = currentNode?.next
    return current
  }
}

class LinkedList <T: Comparable & CustomStringConvertible>: CustomStringConvertible, Sequence {
  
  private var firstNode: Node<T>?
  
  var length: UInt {
    var count: UInt = 0
    for _ in self {
      count += 1
    }
    return count
  }
  
  var description: String {
    guard let first = firstNode else {
      return "[]"
    }
    var startMarker = "["
    return first.recursiveDescription(precedingString: &startMarker)
  }
  
  init() {
  }
  
  init(firstNode: Node<T>) {
    self.firstNode = firstNode
  }
  
  func first() -> Node<T>? {
    return firstNode
  }
  
  func last() -> Node<T>? {
    var current = firstNode
    var next = firstNode?.next
    while next != nil {
      current = next
      next = next?.next
    }
    return current
  }
  
  func nodeAtPosition(index: UInt) -> Node<T>? {
    var nodeToReturn: Node<T>?
    var iterator: UInt = 0
    for node in self {
      nodeToReturn = node
      if iterator == index {
        break
      }
      iterator += 1
    }
    return nodeToReturn
  }
  
  func makeIterator() -> LinkedListIterator<T> {
    return LinkedListIterator(firstNode: firstNode)
  }
  
  func contains(node nodeToCheck: Node<T>) -> Bool {
    var containsNode = false
    
    for node in self {
      if node == nodeToCheck {
        containsNode = true
      }
    }
    
    return containsNode
  }
  
  func insertAtBegining(newFirst: Node<T>) {
    newFirst.next = firstNode
    firstNode = newFirst
  }
  
  func insert(newNode: Node<T>, beforeNode node:Node<T>) {
    let newNodeCopy = Node(value: newNode.value)
    newNodeCopy.next = node.next
    node.next = newNodeCopy
    let oldNodeValue = node.value
    node.value = newNodeCopy.value
    newNodeCopy.value = oldNodeValue
  }
  
  func insert(newNode: Node<T>, afterNode node: Node<T>) {
    newNode.next = node.next
    node.next = newNode
  }
  
  func append(node: Node<T>) {
    if let first = firstNode {
      first.append(node: node)
    }
    else {
      firstNode = node
    }
  }
  
  func appendContentsOf(list: LinkedList<T>) {
    last()?.next = list.first()
  }
  
  func removeFirst() {
    firstNode = firstNode?.next
  }
  
  func removeNode(node: Node<T>) {
    guard let nextNode = node.next else {
      return
    }
    node.value = nextNode.value
    node.next = nextNode.next
  }
  
  func removeAfter(node: Node<T>) {
    node.next = node.next?.next
  }
  
  func removeAllAfter(node: Node<T>) {
    node.next = nil
  }
  
  func toArray() -> [T] {
    var array = [T]()
    for node in self {
      array.append(node.value)
    }
    return array
  }
  
  func sort() {
    let listLength = length
    
    if listLength < 2 {
      return
    }
    
    guard let first = firstNode else {
      return
    }
    
    let sublistLength = listLength / 2
    
    let leftList = LinkedList(firstNode: first)
    
    guard let rightNode = nodeAtPosition(index: sublistLength) else {
      return
    }
    let rightList = LinkedList(firstNode: rightNode)
    
    leftList.nodeAtPosition(index: sublistLength - 1)?.next = nil
    
    leftList.sort()
    rightList.sort()
    
    leftList.mergeInItemsFromList(otherList: rightList)
    self.firstNode = leftList.firstNode
  }
  
  func mergeInItemsFromList(otherList:LinkedList<T>) {
    guard let _ = firstNode, let _ = otherList.first() else {
      return
    }
    
    guard var lastCompared = self.firstNode else {
      return
    }
    
    while otherList.length > 0 {
      guard let otherFirst = otherList.first() else {
        break
      }
      if otherFirst < lastCompared {
        insert(newNode: otherFirst, beforeNode: lastCompared)
        otherList.removeFirst()
      }
      if let lastComparedNext = lastCompared.next {
        lastCompared = lastComparedNext
      }
      else {
        break
      }
    }
    
    if otherList.length > 0 {
      appendContentsOf(list: otherList)
    }
  }
  
  //private
  
  private func swapNodeValues(node1:Node<T>, node2:Node<T>) {
    if !contains(node: node1) || !contains(node: node2) {
      return
    }
    
    let node1Value = node1.value
    let node2Value = node2.value
    
    node1.value = node2Value
    node2.value = node1Value
  }
  
  private func nodeAtPosition(_ steps: UInt, stepsToTheRightOfNode node:Node<T>?) -> Node<T>? {
    if node == nil {
      return nil
    }
    if steps == 0 {
      return node
    }
    var nextNode: Node<T>? = node
    for _ in 1...steps {
      nextNode = nextNode?.next
      if nextNode == nil {
        break
      }
    }
    return nextNode
  }
  
}

//DEMONSTRATION

let linkedList = LinkedList(firstNode: Node(value: 15))
linkedList.append(node: Node(value: 2))
linkedList.append(node: Node(value: 8))
linkedList.append(node: Node(value: 81))
linkedList.append(node: Node(value: 7))
print(linkedList)
print("\nSorting...")

linkedList.sort()
print(linkedList)

print("\nInsert big value at beginning:")
linkedList.insertAtBegining(newFirst: Node(value: 99))
print(linkedList)

print("\nAnd sort again...")

linkedList.sort()
print(linkedList)
print("\nBooyah.")