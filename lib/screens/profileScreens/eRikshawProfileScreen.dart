import 'package:flutter/material.dart';

class DriverssssProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top Section with Header & Cover
                  _buildTopSection(context),
                  
                  // Driver Details Section
                  _buildDriverDetailsSection(),
                  
                  // Media Section
                  _buildMediaSection(),
                  
                  // Extra padding for bottom navigation
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Container(
      height: 280,
      child: Stack(
        children: [
          // Gradient Background
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple[400]!,
                  Colors.orange[300]!,
                  Colors.white,
                ],
              ),
            ),
          ),
          
          // Cover Image Banner
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800&h=400&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Profile Picture
          Positioned(
            top: 130,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Driver Info
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Rajesh Kumar',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text(
                      '4.3',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 20),
                    _buildActionButton(Icons.chat_bubble_outline, Colors.purple),
                    SizedBox(width: 12),
                    _buildActionButton(Icons.call, Colors.green),
                    SizedBox(width: 12),
                    _buildActionButton(Icons.message, Colors.green[600]!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildDriverDetailsSection() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(Icons.phone, '+91 98765 43210'),
          SizedBox(height: 15),
          _buildDetailRow(Icons.location_on, 'Sector 15, Gurugram, Haryana'),
          SizedBox(height: 15),
          _buildDetailRow(Icons.airline_seat_recline_normal, '4 Seats'),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.directions_car, color: Colors.grey[600], size: 20),
              SizedBox(width: 12),
              Text(
                'DL 8C AB 1234',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.currency_rupee, color: Colors.grey[600], size: 20),
              SizedBox(width: 12),
              Text(
                '₹499 Minimum',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Negotiable',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _buildDetailRow(Icons.work_outline, '2 Years Experience'),
          SizedBox(height: 20),
          
          // Languages
          Text(
            'Spoken Languages',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildChip('Hindi', Colors.blue),
              _buildChip('English', Colors.green),
              _buildChip('Tamil', Colors.orange),
            ],
          ),
          SizedBox(height: 15),
          
          // Service Locations
          Text(
            'Service Locations',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildChip('Delhi', Colors.purple),
              _buildChip('Gurugram', Colors.purple),
              _buildChip('Noida', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color.withOpacity(.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video and Images',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                List<String> images = [
                  'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=200&h=150&fit=crop',
                  'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=200&h=150&fit=crop',
                  'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=200&h=150&fit=crop',
                  'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=200&h=150&fit=crop',
                  'https://images.unsplash.com/photo-1494976688153-018c804d5012?w=200&h=150&fit=crop',
                ];
                
                return Container(
                  width: 160,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(images[index % images.length]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: index == 0
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple[600],
        unselectedItemColor: Colors.grey[600],
        currentIndex: 0,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Partner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}