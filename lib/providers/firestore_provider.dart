import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

// Re-export EventData, AnnouncementData, TeamData, TeamMemberData, SponsorData, HomeSectionData, and AboutSectionData for convenience
export '../services/firestore_service.dart' show EventData, AnnouncementData, TeamData, TeamMemberData, SponsorData, HomeSectionData, AboutSectionData;

class FirestoreProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  FirestoreService get firestoreService => _firestoreService;

  // Events
  Stream<List<EventData>> getEvents() {
    return _firestoreService.getEvents();
  }

  Future<void> addEvent(EventData event) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.addEvent(event);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<DocumentReference> addEventAndGetRef(EventData event) async {
    try {
      _setLoading(true);
      _error = null;
      final docRef = await _firestoreService.addEventAndGetRef(event);
      _setLoading(false);
      notifyListeners();
      return docRef;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEvent(String eventId, EventData event) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateEvent(eventId, event);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.deleteEvent(eventId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Admin registration
  Future<String> registerPendingAdmin(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      _setLoading(true);
      _error = null;
      final token = await _firestoreService.registerPendingAdmin(
        firstName,
        lastName,
        email,
        password,
      );
      _setLoading(false);
      notifyListeners();
      return token;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Verify admin
  Future<Map<String, String>> verifyAdmin(String token) async {
    try {
      _setLoading(true);
      _error = null;
      final result = await _firestoreService.verifyAdmin(token);
      _setLoading(false);
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Reject admin
  Future<void> rejectAdmin(String token) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.rejectAdmin(token);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Delete all pending admins
  Future<int> deleteAllPendingAdmins() async {
    try {
      _setLoading(true);
      _error = null;
      final count = await _firestoreService.deleteAllPendingAdmins();
      _setLoading(false);
      notifyListeners();
      return count;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Check if admin is verified
  Future<bool> isAdminVerified(String email) async {
    try {
      return await _firestoreService.isAdminVerified(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Contact settings
  Stream<Map<String, dynamic>> getContactSettingsStream() {
    return _firestoreService.getContactSettingsStream();
  }

  Future<Map<String, dynamic>> getContactSettings() async {
    try {
      return await _firestoreService.getContactSettings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateContactSettings(Map<String, dynamic> settings) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateContactSettings(settings);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Site settings
  Stream<Map<String, dynamic>> getSiteSettingsStream() {
    return _firestoreService.getSiteSettingsStream();
  }

  Future<Map<String, dynamic>> getSiteSettings() async {
    try {
      return await _firestoreService.getSiteSettings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSiteSettings(Map<String, dynamic> settings) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateSiteSettings(settings);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Statistics
  Stream<Map<String, dynamic>> getStatisticsStream() {
    return _firestoreService.getStatisticsStream();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      return await _firestoreService.getStatistics();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStatistics(Map<String, dynamic> statistics) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateStatistics(statistics);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Announcements
  Stream<List<AnnouncementData>> getAnnouncements({int? limit}) {
    return _firestoreService.getAnnouncements(limit: limit);
  }

  Stream<List<AnnouncementData>> getAnnouncementsByType(String type) {
    return _firestoreService.getAnnouncementsByType(type);
  }

  Future<void> addAnnouncement(AnnouncementData announcement) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.addAnnouncement(announcement);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<DocumentReference> addAnnouncementAndGetRef(AnnouncementData announcement) async {
    try {
      _setLoading(true);
      _error = null;
      final ref = await _firestoreService.addAnnouncementAndGetRef(announcement);
      _setLoading(false);
      notifyListeners();
      return ref;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAnnouncement(String announcementId, AnnouncementData announcement) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateAnnouncement(announcementId, announcement);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.deleteAnnouncement(announcementId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Teams
  Stream<List<TeamData>> getTeams() {
    return _firestoreService.getTeams();
  }

  Future<void> addTeam(TeamData team) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.addTeam(team);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<DocumentReference> addTeamAndGetRef(TeamData team) async {
    try {
      _setLoading(true);
      _error = null;
      final docRef = await _firestoreService.addTeamAndGetRef(team);
      _setLoading(false);
      notifyListeners();
      return docRef;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTeam(String teamId, TeamData team) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateTeam(teamId, team);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTeam(String teamId) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.deleteTeam(teamId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Team Members
  Stream<List<TeamMemberData>> getTeamMembers(String teamId) {
    return _firestoreService.getTeamMembers(teamId);
  }

  Stream<List<TeamMemberData>> getAllTeamMembers() {
    return _firestoreService.getAllTeamMembers();
  }

  Future<void> addTeamMember(TeamMemberData member) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.addTeamMember(member);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<DocumentReference> addTeamMemberAndGetRef(TeamMemberData member) async {
    try {
      _setLoading(true);
      _error = null;
      final docRef = await _firestoreService.addTeamMemberAndGetRef(member);
      _setLoading(false);
      notifyListeners();
      return docRef;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTeamMember(String memberId, TeamMemberData member) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateTeamMember(memberId, member);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTeamMember(String memberId) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.deleteTeamMember(memberId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Sponsors
  Stream<List<SponsorData>> getSponsors() {
    return _firestoreService.getSponsors();
  }

  Future<void> addSponsor(SponsorData sponsor) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.addSponsor(sponsor);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<DocumentReference> addSponsorAndGetRef(SponsorData sponsor) async {
    try {
      _setLoading(true);
      _error = null;
      final docRef = await _firestoreService.addSponsorAndGetRef(sponsor);
      _setLoading(false);
      notifyListeners();
      return docRef;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSponsor(String sponsorId, SponsorData sponsor) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateSponsor(sponsorId, sponsor);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSponsor(String sponsorId) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.deleteSponsor(sponsorId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // Home Sections
  Stream<List<HomeSectionData>> getHomeSections() {
    return _firestoreService.getHomeSections();
  }

  Future<void> addHomeSection(HomeSectionData section) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.addHomeSection(section);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<DocumentReference> addHomeSectionAndGetRef(HomeSectionData section) async {
    try {
      _setLoading(true);
      _error = null;
      final docRef = await _firestoreService.addHomeSectionAndGetRef(section);
      _setLoading(false);
      notifyListeners();
      return docRef;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateHomeSection(String sectionId, HomeSectionData section) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateHomeSection(sectionId, section);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteHomeSection(String sectionId) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.deleteHomeSection(sectionId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  // About Sections
  Stream<List<AboutSectionData>> getAboutSections() {
    return _firestoreService.getAboutSections();
  }

  Future<void> addAboutSection(AboutSectionData section) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.addAboutSection(section);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAboutSection(String sectionId, AboutSectionData section) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.updateAboutSection(sectionId, section);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAboutSection(String sectionId) async {
    try {
      _setLoading(true);
      _error = null;
      await _firestoreService.deleteAboutSection(sectionId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

