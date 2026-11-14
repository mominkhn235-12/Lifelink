import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';

class RequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Saves a new request. Returns null on success, or an error message.
  Future<String?> createRequest(RequestModel request) async {
    try {
      await _db.collection('requests').add(request.toMap());
      return null;
    } catch (e) {
      return 'Could not save the request. Please try again.';
    }
  }

  // Live list of one requester's own requests, newest first.
  Stream<List<RequestModel>> myRequests(String uid) {
    return _db
        .collection('requests')
        .where('requesterId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => RequestModel.fromDoc(d)).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
      return list;
    });
  }

  // Live list of all open requests (the donor screen filters these).
  Stream<List<RequestModel>> openRequests() {
    return _db
        .collection('requests')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => RequestModel.fromDoc(d)).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
      return list;
    });
  }

  // Changes the status of a request (open, accepted, fulfilled, cancelled).
  Future<String?> updateStatus(String requestId, String status) async {
    try {
      await _db.collection('requests').doc(requestId).update({
        'status': status,
      });
      return null;
    } catch (e) {
      return 'Could not update the request.';
    }
  }
    // A donor accepts an open request.
  Future<String?> acceptRequest({
    required String requestId,
    required String donorId,
    required String donorName,
    required String donorPhone,
  }) async {
    try {
      await _db.collection('requests').doc(requestId).update({
        'status': 'accepted',
        'acceptedBy': donorId,
        'acceptedByName': donorName,
        'acceptedByPhone': donorPhone,
      });
      return null;
    } catch (e) {
      return 'Could not accept the request.';
    }
  }
    // Admin approves a request so donors can see it.
  Future<String?> verifyRequest(String requestId) async {
    try {
      await _db.collection('requests').doc(requestId).update({
        'isVerified': true,
      });
      return null;
    } catch (e) {
      return 'Could not approve the request.';
    }
  }
}