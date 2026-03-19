let users = [];

exports.createUser = (req, res) => {

  const { id, email } = req.body;

  const user = {
    id,
    email,
    name: ""
  };

  users.push(user);

  res.json({
    message: "User created",
    user
  });

};

exports.getProfile = (req, res) => {

  const user = users.find(u => u.id === req.user.id);

  if (!user) {
    return res.json({ message: "User not found" });
  }

  res.json(user);

};

exports.updateProfile = (req, res) => {

  const user = users.find(u => u.id === req.user.id);

  if (!user) {
    return res.json({ message: "User not found" });
  }

  user.name = req.body.name || user.name;

  res.json({
    message: "Profile updated",
    user
  });

};